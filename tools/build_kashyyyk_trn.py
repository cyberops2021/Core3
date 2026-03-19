#!/usr/bin/env python3
"""
Build terrain/kashyyyk_main.trn by patching rori.trn's embedded filename,
then pack into a minimal TRE.

IFF Structure of a .trn:
  FORM PTAT (size=...)
    FORM 0014 (size=...)
      DATA (size=...)   <-- contains embedded source path + terrain params
      FORM TGEN (size=...)
      FORM 0001 (size=...)
      ...

The DATA chunk has:
  - Null-terminated source path (e.g. "C:\...\terrain\rori.trn")
  - Terrain parameters (floats, ints, shader name, etc.)

We patch the source path and update all IFF FORM/DATA sizes.
"""

import struct
import zlib
import hashlib
import os

TRE_PATH = "/home/swgemu/Desktop/SWGEmu/data_other_00.tre"
OUTPUT_TRE = "/home/blueteam1/workspace/Core3/tools/patch_kashyyyk_terrain.tre"
DEPLOY_TRE = "/home/swgemu/Desktop/SWGEmu/patch_kashyyyk_terrain.tre"

OLD_FILENAME = b"rori.trn"
NEW_FILENAME = b"kashyyyk_main.trn"

# --- TRE reading ---

def extract_from_tre(tre_path, target_name):
    with open(tre_path, 'rb') as f:
        f.read(4)  # magic EERT
        f.read(4)  # version 5000
        total_records = struct.unpack('<I', f.read(4))[0]
        data_offset = struct.unpack('<I', f.read(4))[0]
        fb_ct = struct.unpack('<I', f.read(4))[0]
        fb_cs = struct.unpack('<I', f.read(4))[0]
        nb_ct = struct.unpack('<I', f.read(4))[0]
        nb_cs = struct.unpack('<I', f.read(4))[0]
        nb_us = struct.unpack('<I', f.read(4))[0]

        f.seek(data_offset)
        rec_data = f.read(fb_cs)
        if fb_ct == 2:
            rec_data = zlib.decompress(rec_data)

        name_data = f.read(nb_cs)
        if nb_ct == 2:
            name_data = zlib.decompress(name_data)

        for i in range(total_records):
            off = i * 24
            ck, us, fo, ct, cs, no = struct.unpack_from('<6I', rec_data, off)
            end = name_data.index(b'\x00', no)
            name = name_data[no:end].decode('ascii')
            if name == target_name:
                f.seek(fo)
                raw = f.read(cs)
                if ct == 2:
                    file_data = zlib.decompress(raw)
                else:
                    file_data = raw
                assert len(file_data) == us
                return file_data
    return None


def patch_trn(data):
    """
    Patch the embedded filename in the TRN's first DATA chunk.
    Returns the patched TRN data.
    """
    # Verify IFF structure
    assert data[0:4] == b'FORM', f"Expected FORM, got {data[0:4]}"
    ptat_size = struct.unpack('>I', data[4:8])[0]
    assert data[8:12] == b'PTAT', f"Expected PTAT, got {data[8:12]}"

    assert data[12:16] == b'FORM', f"Expected inner FORM, got {data[12:16]}"
    inner_form_size = struct.unpack('>I', data[16:20])[0]
    assert data[20:24] == b'0014', f"Expected 0014, got {data[20:24]}"

    # DATA chunk at offset 24
    assert data[24:28] == b'DATA', f"Expected DATA, got {data[24:28]}"
    data_chunk_size = struct.unpack('>I', data[28:32])[0]
    data_content = data[32:32 + data_chunk_size]

    # Find the embedded filename (null-terminated string)
    null_pos = data_content.index(b'\x00')
    old_path = data_content[:null_pos]
    remaining = data_content[null_pos:]  # includes the null byte + rest of params

    print(f"  Old embedded path: {old_path.decode('ascii')}")
    print(f"  Old path length: {len(old_path)}")

    # Find and replace the filename part
    # Old: ...\\terrain\\rori.trn
    # New: ...\\terrain\\kashyyyk_main.trn
    old_suffix = b"\\terrain\\" + OLD_FILENAME
    new_suffix = b"\\terrain\\" + NEW_FILENAME

    if old_suffix not in old_path:
        # Try forward slash
        old_suffix = b"/terrain/" + OLD_FILENAME
        new_suffix = b"/terrain/" + NEW_FILENAME

    assert old_suffix in old_path, f"Cannot find '{old_suffix}' in path '{old_path}'"

    new_path = old_path.replace(old_suffix, new_suffix)
    print(f"  New embedded path: {new_path.decode('ascii')}")
    print(f"  New path length: {len(new_path)}")

    size_delta = len(new_path) - len(old_path)
    print(f"  Size delta: {size_delta:+d} bytes")

    # Build new DATA content
    new_data_content = new_path + remaining
    new_data_chunk_size = len(new_data_content)

    # Build new DATA chunk
    new_data_chunk = b'DATA' + struct.pack('>I', new_data_chunk_size) + new_data_content

    # Everything after the original DATA chunk
    after_data = data[32 + data_chunk_size:]

    # Rebuild the file with updated FORM sizes
    new_inner_form_size = inner_form_size + size_delta
    new_ptat_size = ptat_size + size_delta

    result = bytearray()
    result += b'FORM'
    result += struct.pack('>I', new_ptat_size)
    result += b'PTAT'
    result += b'FORM'
    result += struct.pack('>I', new_inner_form_size)
    result += b'0014'
    result += new_data_chunk
    result += after_data

    print(f"  Old TRN size: {len(data)}")
    print(f"  New TRN size: {len(result)}")
    assert len(result) == len(data) + size_delta

    # Verify the patched file still has valid IFF structure
    assert result[0:4] == b'FORM'
    check_size = struct.unpack('>I', result[4:8])[0]
    assert check_size + 8 == len(result), f"FORM size mismatch: {check_size + 8} vs {len(result)}"

    return bytes(result)


def build_tre(output_path, file_name, file_data):
    """Build a minimal TRE version 0005 containing a single file."""
    compressed_data = zlib.compress(file_data)

    file_offset = 36  # right after header
    name_bytes = file_name.encode('ascii') + b'\x00'

    record = struct.pack('<6I',
        0,                      # checksum
        len(file_data),         # uncompressed size
        file_offset,            # file offset
        2,                      # compression type (zlib)
        len(compressed_data),   # compressed size
        0,                      # name offset
    )

    records_compressed = zlib.compress(record)
    names_compressed = zlib.compress(name_bytes)
    data_offset = 36 + len(compressed_data)

    header = b'EERT'  # TREE magic
    header += b'5000'  # version 0005
    header += struct.pack('<I', 1)
    header += struct.pack('<I', data_offset)
    header += struct.pack('<I', 2)  # file block: zlib
    header += struct.pack('<I', len(records_compressed))
    header += struct.pack('<I', 2)  # name block: zlib
    header += struct.pack('<I', len(names_compressed))
    header += struct.pack('<I', len(name_bytes))

    md5 = hashlib.md5(file_data).digest()

    with open(output_path, 'wb') as f:
        f.write(header)
        f.write(compressed_data)
        f.write(records_compressed)
        f.write(names_compressed)
        f.write(md5)

    total = 36 + len(compressed_data) + len(records_compressed) + len(names_compressed) + 16
    print(f"  TRE size: {total} bytes")
    print(f"  File data: {len(file_data)} -> {len(compressed_data)} compressed")
    return total


def verify_tre(tre_path):
    """Verify the TRE can be read back correctly."""
    with open(tre_path, 'rb') as f:
        f.read(4)  # magic
        f.read(4)  # version
        total = struct.unpack('<I', f.read(4))[0]
        data_off = struct.unpack('<I', f.read(4))[0]
        fb_ct = struct.unpack('<I', f.read(4))[0]
        fb_cs = struct.unpack('<I', f.read(4))[0]
        nb_ct = struct.unpack('<I', f.read(4))[0]
        nb_cs = struct.unpack('<I', f.read(4))[0]
        nb_us = struct.unpack('<I', f.read(4))[0]

        f.seek(data_off)
        rec_data = f.read(fb_cs)
        if fb_ct == 2:
            rec_data = zlib.decompress(rec_data)

        ck, us, fo, ct, cs, no = struct.unpack_from('<6I', rec_data, 0)

        name_data = f.read(nb_cs)
        if nb_ct == 2:
            name_data = zlib.decompress(name_data)
        end = name_data.index(b'\x00', no)
        name = name_data[no:end].decode('ascii')

        f.seek(fo)
        raw = f.read(cs)
        if ct == 2:
            extracted = zlib.decompress(raw)
        else:
            extracted = raw

        print(f"  File: '{name}'")
        print(f"  Size: {len(extracted)} bytes")

        # Verify IFF
        assert extracted[0:4] == b'FORM'
        form_size = struct.unpack('>I', extracted[4:8])[0]
        assert form_size + 8 == len(extracted), f"IFF size check failed"
        assert extracted[8:12] == b'PTAT'

        # Check embedded filename
        assert extracted[24:28] == b'DATA'
        ds = struct.unpack('>I', extracted[28:32])[0]
        content = extracted[32:32+ds]
        null = content.index(b'\x00')
        embedded = content[:null].decode('ascii')
        print(f"  Embedded path: '{embedded}'")

        return extracted


def main():
    print("=" * 60)
    print("Step 1: Extract terrain/rori.trn")
    print("=" * 60)
    rori_data = extract_from_tre(TRE_PATH, "terrain/rori.trn")
    assert rori_data is not None, "Failed to extract rori.trn"
    print(f"  Extracted {len(rori_data)} bytes")

    print()
    print("=" * 60)
    print("Step 2: Patch embedded filename")
    print("=" * 60)
    patched = patch_trn(rori_data)

    # Save the patched TRN for inspection
    trn_path = "/home/blueteam1/workspace/Core3/tools/kashyyyk_main.trn"
    with open(trn_path, 'wb') as f:
        f.write(patched)
    print(f"  Saved patched TRN: {trn_path}")

    print()
    print("=" * 60)
    print("Step 3: Build TRE")
    print("=" * 60)
    build_tre(OUTPUT_TRE, "terrain/kashyyyk_main.trn", patched)
    print(f"  Output: {OUTPUT_TRE}")

    print()
    print("=" * 60)
    print("Step 4: Verify")
    print("=" * 60)
    extracted = verify_tre(OUTPUT_TRE)
    if extracted == patched:
        print("  DATA INTEGRITY: OK")
    else:
        print("  DATA INTEGRITY: FAILED!")
        return

    # Show summary of all rori references remaining in the patched data
    print()
    print("=" * 60)
    print("Remaining 'rori' references in patched TRN")
    print("=" * 60)
    pos = 0
    count = 0
    while True:
        pos = patched.find(b'rori', pos)
        if pos == -1:
            break
        start = max(0, pos - 20)
        end = min(len(patched), pos + 30)
        context = patched[start:end]
        print(f"  offset {pos}: ...{context}...")
        pos += 1
        count += 1
    print(f"  Total remaining references: {count}")
    print("  (These are texture/shader names - they reference existing rori assets)")
    print("  (The client should still render using rori textures, which is fine for testing)")

    print()
    print("=" * 60)
    print("DONE")
    print("=" * 60)
    print(f"\nBuilt: {OUTPUT_TRE}")
    print(f"Contains: terrain/kashyyyk_main.trn ({len(patched)} bytes)")
    print(f"  Embedded path: ...\\terrain\\kashyyyk_main.trn")
    print(f"  PTAT version: 0014")
    print(f"  Terrain data: rori (same heightmap, textures)")
    print()
    print("To deploy:")
    print(f"  1. Copy to SWG data dir:")
    print(f"     cp {OUTPUT_TRE} {DEPLOY_TRE}")
    print(f"  2. Add to config.lua TreFiles (before data_other_00.tre):")
    print(f'     "patch_kashyyyk_terrain.tre",')


if __name__ == '__main__':
    main()
