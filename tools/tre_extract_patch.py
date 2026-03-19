#!/usr/bin/env python3
"""
Extract rori.trn from data_other_00.tre, patch embedded filename to kashyyyk_main.trn,
and build a minimal TRE containing just the patched file.
"""

import struct
import zlib
import hashlib
import sys
import os

TRE_PATH = "/home/swgemu/Desktop/SWGEmu/data_other_00.tre"
OUTPUT_TRE = "/home/blueteam1/workspace/Core3/tools/patch_kashyyyk_terrain.tre"
TARGET_FILE = "terrain/rori.trn"
NEW_INTERNAL_NAME = "terrain/kashyyyk_main.trn"

def read_tre_header(f):
    magic = f.read(4)
    assert magic == b'EERT', f"Bad magic: {magic}"
    version = f.read(4)
    assert version == b'5000', f"Bad version: {version}"
    total_records = struct.unpack('<I', f.read(4))[0]
    data_offset = struct.unpack('<I', f.read(4))[0]
    fb_comp_type = struct.unpack('<I', f.read(4))[0]
    fb_comp_size = struct.unpack('<I', f.read(4))[0]
    nb_comp_type = struct.unpack('<I', f.read(4))[0]
    nb_comp_size = struct.unpack('<I', f.read(4))[0]
    nb_uncomp_size = struct.unpack('<I', f.read(4))[0]
    return {
        'total_records': total_records,
        'data_offset': data_offset,
        'fb_comp_type': fb_comp_type,
        'fb_comp_size': fb_comp_size,
        'nb_comp_type': nb_comp_type,
        'nb_comp_size': nb_comp_size,
        'nb_uncomp_size': nb_uncomp_size,
    }

def decompress_block(f, comp_type, comp_size, uncomp_size):
    data = f.read(comp_size)
    if comp_type == 2:
        return zlib.decompress(data)
    return data

def extract_file_from_tre(tre_path, target_name):
    """Extract a single file from a TRE archive. Returns the raw bytes."""
    with open(tre_path, 'rb') as f:
        hdr = read_tre_header(f)
        print(f"TRE has {hdr['total_records']} records, data_offset={hdr['data_offset']}")

        # Seek to file records block (at data_offset)
        f.seek(hdr['data_offset'])

        # Decompress file records block
        record_uncomp_size = hdr['total_records'] * 24  # 6 x uint32 per record
        file_block_data = decompress_block(f, hdr['fb_comp_type'], hdr['fb_comp_size'], record_uncomp_size)
        print(f"File records block: {len(file_block_data)} bytes uncompressed")

        # Parse records
        records = []
        for i in range(hdr['total_records']):
            off = i * 24
            checksum, uncomp_size, file_offset, comp_type, comp_size, name_offset = \
                struct.unpack_from('<6I', file_block_data, off)
            records.append({
                'checksum': checksum,
                'uncomp_size': uncomp_size,
                'file_offset': file_offset,
                'comp_type': comp_type,
                'comp_size': comp_size,
                'name_offset': name_offset,
            })

        # Decompress name block
        name_block_data = decompress_block(f, hdr['nb_comp_type'], hdr['nb_comp_size'], hdr['nb_uncomp_size'])
        print(f"Name block: {len(name_block_data)} bytes uncompressed")

        # Find target file
        target_record = None
        for rec in records:
            # Extract null-terminated string from name block
            noff = rec['name_offset']
            end = name_block_data.index(b'\0', noff)
            name = name_block_data[noff:end].decode('ascii')
            if name == target_name:
                target_record = rec
                target_record['name'] = name
                print(f"Found '{name}': offset={rec['file_offset']}, "
                      f"comp_type={rec['comp_type']}, comp_size={rec['comp_size']}, "
                      f"uncomp_size={rec['uncomp_size']}")
                break

        if target_record is None:
            # Try partial match
            print(f"\nERROR: '{target_name}' not found. Searching for partial matches...")
            for rec in records:
                noff = rec['name_offset']
                end = name_block_data.index(b'\0', noff)
                name = name_block_data[noff:end].decode('ascii')
                if 'rori' in name.lower() and '.trn' in name.lower():
                    print(f"  Candidate: '{name}'")
            return None, None

        # Extract the file data
        f.seek(target_record['file_offset'])
        raw_data = f.read(target_record['comp_size'])
        if target_record['comp_type'] == 2:
            file_data = zlib.decompress(raw_data)
        else:
            file_data = raw_data

        assert len(file_data) == target_record['uncomp_size'], \
            f"Size mismatch: got {len(file_data)}, expected {target_record['uncomp_size']}"

        print(f"Extracted {len(file_data)} bytes")
        return file_data, target_record

def find_embedded_filename(data, old_name_fragment):
    """Find occurrences of a filename string in binary data."""
    positions = []
    search = old_name_fragment.encode('ascii')
    pos = 0
    while True:
        pos = data.find(search, pos)
        if pos == -1:
            break
        # Show context
        start = max(0, pos - 16)
        end = min(len(data), pos + len(search) + 16)
        print(f"  Found '{old_name_fragment}' at offset {pos} (0x{pos:x})")
        print(f"    Context: {data[start:end]}")
        positions.append(pos)
        pos += 1
    return positions

def patch_trn_filename(data, old_name, new_name):
    """
    Patch embedded filename in TRN data.
    TRN is IFF format. The filename may be embedded as a string in the terrain data.
    We need to find 'rori' references and replace with 'kashyyyk_main'.

    IMPORTANT: Since kashyyyk_main is longer than rori, we need to be careful.
    Let's first see what's actually in the file.
    """
    print(f"\nSearching for embedded references to 'rori' in TRN data ({len(data)} bytes)...")
    positions = find_embedded_filename(data, 'rori')

    if not positions:
        print("No 'rori' references found in TRN data!")
        # Try other patterns
        find_embedded_filename(data, 'terrain/')
        find_embedded_filename(data, '.trn')

    return data, positions

def build_tre(output_path, file_name, file_data):
    """
    Build a minimal TRE version 0005 containing a single file.

    TRE Layout:
    - Header (36 bytes)
    - File data (compressed)
    - File records block (compressed)
    - Name block (compressed)
    - MD5 sums (16 bytes per record)
    """
    # Compress the file data
    compressed_data = zlib.compress(file_data)
    comp_type = 2
    print(f"\nFile data: {len(file_data)} -> {len(compressed_data)} bytes compressed")

    # Build file record
    # File data starts right after the 36-byte header
    file_offset = 36
    name_bytes = file_name.encode('ascii') + b'\0'

    record = struct.pack('<6I',
        0,                      # checksum (CRC32)
        len(file_data),         # uncompressed size
        file_offset,            # file offset (absolute from start)
        comp_type,              # compression type (2 = zlib)
        len(compressed_data),   # compressed size
        0,                      # name offset (0 = first entry in name block)
    )

    # Compress file records block
    records_compressed = zlib.compress(record)
    fb_comp_type = 2

    # Compress name block
    names_compressed = zlib.compress(name_bytes)
    nb_comp_type = 2

    # Data offset = header + file data
    data_offset = 36 + len(compressed_data)

    # Build header
    header = b'EERT'  # 'TREE' magic
    header += b'5000'  # version '0005'
    header += struct.pack('<I', 1)  # total records
    header += struct.pack('<I', data_offset)
    header += struct.pack('<I', fb_comp_type)  # file block compression
    header += struct.pack('<I', len(records_compressed))  # file block compressed size
    header += struct.pack('<I', nb_comp_type)  # name block compression
    header += struct.pack('<I', len(names_compressed))  # name block compressed size
    header += struct.pack('<I', len(name_bytes))  # name block uncompressed size

    assert len(header) == 36

    # MD5 of the file data
    md5 = hashlib.md5(file_data).digest()

    # Write it all out
    with open(output_path, 'wb') as f:
        f.write(header)
        f.write(compressed_data)
        f.write(records_compressed)
        f.write(names_compressed)
        f.write(md5)

    total_size = 36 + len(compressed_data) + len(records_compressed) + len(names_compressed) + 16
    print(f"Wrote TRE: {output_path} ({total_size} bytes)")
    return total_size

def verify_tre(tre_path):
    """Read back the TRE we just built and verify it."""
    print(f"\nVerifying {tre_path}...")
    with open(tre_path, 'rb') as f:
        hdr = read_tre_header(f)
        print(f"  Records: {hdr['total_records']}, DataOffset: {hdr['data_offset']}")

        f.seek(hdr['data_offset'])
        record_uncomp_size = hdr['total_records'] * 24
        file_block_data = decompress_block(f, hdr['fb_comp_type'], hdr['fb_comp_size'], record_uncomp_size)

        checksum, uncomp_size, file_offset, comp_type, comp_size, name_offset = \
            struct.unpack_from('<6I', file_block_data, 0)
        print(f"  Record: uncomp={uncomp_size}, offset={file_offset}, comp_type={comp_type}, comp_size={comp_size}")

        name_block_data = decompress_block(f, hdr['nb_comp_type'], hdr['nb_comp_size'], hdr['nb_uncomp_size'])
        end = name_block_data.index(b'\0')
        name = name_block_data[:end].decode('ascii')
        print(f"  File name: '{name}'")

        # Extract and verify size
        f.seek(file_offset)
        raw = f.read(comp_size)
        if comp_type == 2:
            extracted = zlib.decompress(raw)
        else:
            extracted = raw
        print(f"  Extracted size: {len(extracted)} (expected {uncomp_size})")
        assert len(extracted) == uncomp_size
        print("  VERIFICATION OK")
        return extracted


def main():
    # Step 1: Extract rori.trn
    print("=" * 60)
    print("STEP 1: Extract rori.trn from data_other_00.tre")
    print("=" * 60)
    file_data, record = extract_file_from_tre(TRE_PATH, TARGET_FILE)
    if file_data is None:
        sys.exit(1)

    # Save raw extraction for reference
    raw_path = "/home/blueteam1/workspace/Core3/tools/rori_extracted.trn"
    with open(raw_path, 'wb') as f:
        f.write(file_data)
    print(f"Saved raw extraction to {raw_path}")

    # Step 2: Analyze the TRN for embedded filename references
    print("\n" + "=" * 60)
    print("STEP 2: Find embedded filename references")
    print("=" * 60)
    patched_data, positions = patch_trn_filename(file_data, 'rori', 'kashyyyk_main')

    # Step 3: Examine the IFF structure
    print("\n" + "=" * 60)
    print("STEP 3: Examine IFF/PTAT structure")
    print("=" * 60)
    # IFF files start with FORM tag
    print(f"First 64 bytes: {file_data[:64]}")
    print(f"First 16 bytes hex: {file_data[:16].hex()}")

    # Look for PTAT
    ptat_pos = file_data.find(b'PTAT')
    if ptat_pos >= 0:
        print(f"PTAT found at offset {ptat_pos}")
        print(f"  Context: {file_data[ptat_pos:ptat_pos+32]}")
        # Read PTAT version (next 4 bytes after the chunk size)
        if ptat_pos + 12 <= len(file_data):
            # IFF: tag(4) + size(4) + sub-tag(4)
            # or FORM tag(4) + size(4) + type(4)
            print(f"  Bytes around PTAT: {file_data[ptat_pos:ptat_pos+16].hex()}")

    # The TRN filename in IFF is typically NOT embedded as a string within the data -
    # it's only the external filename in the TRE directory.
    # The important thing is what the TRE names it.
    # So we just need to pack it with the new name.

    print("\n" + "=" * 60)
    print("STEP 4: Build TRE with kashyyyk_main.trn")
    print("=" * 60)
    print("Note: The TRN data itself doesn't contain its own filename.")
    print("The zone name comes from the TRE directory entry name.")
    print(f"Packing as '{NEW_INTERNAL_NAME}'...")

    build_tre(OUTPUT_TRE, NEW_INTERNAL_NAME, file_data)

    # Step 5: Verify
    print("\n" + "=" * 60)
    print("STEP 5: Verify the new TRE")
    print("=" * 60)
    extracted = verify_tre(OUTPUT_TRE)

    # Verify data matches
    if extracted == file_data:
        print("\n  DATA INTEGRITY CHECK: PASSED - extracted data matches original")
    else:
        print("\n  DATA INTEGRITY CHECK: FAILED!")
        sys.exit(1)

    # Also save the extracted TRN for inspection
    patched_trn_path = "/home/blueteam1/workspace/Core3/tools/kashyyyk_main_from_rori.trn"
    with open(patched_trn_path, 'wb') as f:
        f.write(file_data)
    print(f"\nSaved extracted TRN to {patched_trn_path}")

    print("\n" + "=" * 60)
    print("DONE!")
    print("=" * 60)
    print(f"\nOutput TRE: {OUTPUT_TRE}")
    print(f"Contains: {NEW_INTERNAL_NAME} (rori terrain data, {len(file_data)} bytes)")
    print(f"\nTo use: Add 'patch_kashyyyk_terrain.tre' to your TRE load list in config.lua")
    print(f"  (place it BEFORE data_other_00.tre so it takes priority)")


if __name__ == '__main__':
    main()
