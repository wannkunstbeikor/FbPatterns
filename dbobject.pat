#pragma once

#include <type/leb128.pat>
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
    } [[sealed, format("type::impl::format_sha1")]];

    struct GUID
    {
        u32 a;
        u16 b;
        u16 c;
        u8 d[8];
    } [[sealed, format("type::impl::format_guid")]];

    namespace impl
    {
		fn format_guid(GUID guid)
        {
	        return std::format("{{{:08X}-{:04X}-{:04X}-{:02X}{:02X}-{:02X}{:02X}{:02X}{:02X}{:02X}{:02X}}}",
	            guid.a,
	            guid.b,
	            guid.c,
	            guid.d[0],
	            guid.d[1],
	            guid.d[2],
	            guid.d[3],
	            guid.d[4],
	            guid.d[5],
	            guid.d[6],
	            guid.d[7]);
	    };

        fn format_sha1(SHA1 sha1)
        {
	        return std::format("{{{:08X}{:08X}{:08X}{:08X}}}",
	            be u32(sha1.a),
                be u32(sha1.b),
                be u32(sha1.c),
                be u32(sha1.d));
	    };
	}
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
                DbObjectElement value[while($ < addressof(size) + sizeof(size) + size)] [[name(name)]];
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
