#ifndef WATER_MASK_DATA_H
#define WATER_MASK_DATA_H

#include "engine/engine.h"

class WaterMaskData {
public:
    static bool isWater(const String& planet, float x, float y);

private:
    static const bool corellia_mask[256][256];
    static const bool dantooine_mask[256][256];
    static const bool dathomir_mask[256][256];
    static const bool endor_mask[256][256];
    static const bool lok_mask[256][256];
    static const bool naboo_mask[256][256];
    static const bool rori_mask[256][256];
    static const bool talus_mask[256][256];
    static const bool tatooine_mask[256][256];
    static const bool yavin4_mask[256][256];
};

#endif
