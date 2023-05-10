#pragma once

// these files can get really large so we need to increase the limit
#pragma pattern_limit 0x4000

#include <fb/obfsheader.pat>
#include <fb/guid.pat>

#include <std/io.pat>
#include <std/mem.pat>

namespace fb
{
    namespace BinarySuperBundleToc
    {
        bitfield Flags
        {
            unused : 29;
            bool hasHuffmanTable : 1;
            bool hasBaseChunks : 1;
            bool hasBaseBundles : 1;
        };

        struct Header
        {
            be u32 pBundleHashMap;
            be u32 pBundleInfo;
            be u32 bundleCount;

            be u32 pChunkHashMap;
            be u32 pChunkInfo;
            be u32 chunkCount;

            // probably sth crypto related not used in any of the released games using this format
            u32;
            u32;

            be u32 pStringTable;

            // just a u32 array with data for the superbundle chunks
            be u32 pChunkData;
            be u32 chunkDataCount;

            be Flags flags;

            if (flags.hasHuffmanTable)
            {
                // newer games use a huffman table to compress the strings
                be u32 stringCount;
                be u32 huffmanNodeCount;
                be u32 phuffmanTable;
            }
            else
            {
                u32 stringCount = 0;
                u32 huffmanNodeCount = 0;
                u32 phuffmanTable = 0;
            }
        };

        fn DecodeHuffmanString(u32 bitIndex)
        {
            str name = "";
            while (true)
            {
                // this is a bug in the pattern language, a while loop increases the times u have to call parent
                // might be fixed in a future version so this would need to be updated
                s32 value = parent.parent.parent.header.huffmanNodeCount / 2 - 1;
                while (true)
                {
                    u32 childIndex = (parent.parent.parent.parent.stringTable[bitIndex / 32] >> (bitIndex % 32)) & 1;
                    value = parent.parent.parent.parent.huffmanTable[value * 2 + childIndex];
                    bitIndex = bitIndex + 1;
                    if (value < 0)
                    {
                        break;
                    }
                }
                name = name + str(-1 - value);
                if (-1 -value == 0)
                {
                    break;
                }
            }
            return name;
        };

        struct HuffmanStringHelper<auto value>
        {
            str string = value;
        } [[format("fb::BinarySuperBundleToc::format_huffman_string_helper")]];

        fn format_huffman_string_helper(ref auto helper)
        {
            return helper.string;
        };

        bitfield FlagAndSize
        {
            unknown : 1;
            isStoredInToc : 1;
            size : 30;
        };

        struct BundleInfo
        {
            be u32 nameOffset [[hidden]];

            if (parent.header.flags.hasHuffmanTable)
            {
                str name = fb::BinarySuperBundleToc::DecodeHuffmanString(nameOffset);

                HuffmanStringHelper<name> helper [[name("name")]];
            }
            else
            {
                char name[] @ addressof(parent.header) + parent.header.pStringTable + nameOffset;
            }

            be FlagAndSize bundleSize;
            be u64 bundleOffset;
        };

        bitfield CasRef
        {
            unused : 8;
            bool isPatch : 8;
            casIndex : 8;
            installChunkIndex : 8;
        };

        fn format_flag_index(u32 flagAndIndex)
        {
            return std::format("{{ flag({}) | index({}) }}", (flagAndIndex >> 24) & 0xFF, flagAndIndex & 0x00FFFFFF);
        };

        struct ChunkInfo
        {
            fb::GUID chunkId; // this guid is stored reversed for some reason, so d[7], d[6], d[5], d[4], d[3], d[2], d[1], d[0], be c, be b, be a
            be u32 flagAndIndex [[format("fb::BinarySuperBundleToc::format_flag_index")]]; // flag is 1 in all released games

            u32 dataIndex = flagAndIndex & 0x00FFFFFF;
            CasRef casRef @ addressof(parent.header) + parent.header.pChunkData + sizeof(u32) * (dataIndex + 0);
            be u32 offset @ addressof(parent.header) + parent.header.pChunkData + sizeof(u32) * (dataIndex + 1);
            be u32 size @ addressof(parent.header) + parent.header.pChunkData + sizeof(u32) * (dataIndex + 2);
        };
    }

    struct BinarySuperBundleToc
    {
        ObfuscationHeader obfsheader;

        BinarySuperBundleToc::Header header;

        be u32 huffmanTable[header.huffmanNodeCount] @ addressof(header) + header.phuffmanTable;
        be u32 stringTable[header.stringCount] @ addressof(header) + header.pStringTable;

        be u32 bundleHashMap[header.bundleCount] @ addressof(header) + header.pBundleHashMap;

        BinarySuperBundleToc::BundleInfo bundleInfos[header.bundleCount] @ addressof(header) + header.pBundleInfo;

        be u32 chunkHashMap[header.chunkCount] @ addressof(header) + header.pChunkHashMap;

        BinarySuperBundleToc::ChunkInfo chunkInfos[header.chunkCount] @ addressof(header) + header.pChunkInfo;
    };
}