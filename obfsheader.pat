#pragma once

namespace fb
{
    struct ObfuscationHeader
    {
        u32 magic;
        u32 unused;
        u8 unk1[256];
        u8 unk2[289];
        padding[3];
    };
}