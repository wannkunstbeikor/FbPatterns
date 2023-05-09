#pragma once

#include <type/leb128.pat>
#include <type/guid.pat>
#include <std/io.pat>
#include <std/core.pat>
#include <std/string.pat>

namespace type
{
    struct SHA1
    {
        u32 a;
        u32 b;
        u32 c;
        u32 d;
        u32 e;
    };
}

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

    enum Type : u8
    {
        NULL = 0,
        Array = 1,
        Object = 2,
        Boolean = 6,
        String = 7,
        Int = 8,
        Long = 9,
        Single = 11,
        Double = 12,
        Guid = 15,
        Sha1 = 16,
        ByteArray = 19
    };

    bitfield Flags
    {
        Type type : 5;
        unk : 2;
        bool anonymous : 1;
    };

    struct DbObjectElement
    {
        Flags flags [[hidden]];
        
        if (flags.type != Type::NULL && !flags.anonymous)
        {
            char name[] [[hidden]];
        }
        else
        {
            str name = "";
        }
        
        match (flags.type)
        {
            (Type::Array):
            {
                type::uLEB128 size [[hidden]];
                DbObjectElement value[while($ < addressof(size) + sizeof(size) + size)] [[name(name)]];
            }
            (Type::Object):
            {
                type::uLEB128 size [[hidden]];
                DbObjectElement value[while($ < addressof(size) + sizeof(size) + size)] [[inline]];
            }
            (Type::Boolean): bool value [[name(name)]];
            (Type::String):
            {
                type::uLEB128 size [[hidden]];
                char value[size] [[name(name)]];
            }
            (Type::Int): s32 value [[name(name)]];
            (Type::Long): s64 value [[name(name)]];
            (Type::Single): float value [[name(name)]];
            (Type::Double): double value [[name(name)]];
            (Type::Guid): type::GUID value [[name(name)]];
            (Type::Sha1): type::SHA1 value [[name(name)]];
            (Type::ByteArray):
            {
                type::uLEB128 size [[hidden]];
                u8 value[size] [[name(name)]];
            }
        }
    } [[inline]];

    struct DbObject : DbObjectElement
    {
    };

    struct TocFile
    {
        ObfuscationHeader obfsHeader;
        DbObject dbObject;
    };
}
