#pragma once

#include <type/leb128.pat>

#include <fb/guid.pat>
#include <fb/sha1.pat>

namespace fb
{
    namespace DbObject
    {
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
                str name = "{}";
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
                (Type::Guid): GUID value [[name(name)]];
                (Type::Sha1): SHA1 value [[name(name)]];
                (Type::ByteArray):
                {
                    type::uLEB128 size [[hidden]];
                    u8 value[size] [[name(name)]];
                }
            }
        } [[inline]];
    }
    

    struct DbObject : DbObject::DbObjectElement
    {
    };
}
