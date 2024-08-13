--[[

   This Lua script provides 3 interfaces or callbacks for filter_lua:

   - cb_print   => Print records to the standard output
   - cb_drop    => Drop the record
   - cb_replace => Replace record content with a new table

   The key inside each function is to do a proper handling of the
   return values. Each function must return 3 values:

      return code, timestamp, record

   where:

   - code     : -1 record must be deleted
                 0 record not modified, keep the original
                 1 record was modified, replace timestamp and record.
                 2 record was modified, replace record and keep timestamp.
   - timestamp: Unix timestamp with precision (double)
   - record   : Table with multiple key/val

   Uppon return if code == 1 (modified), then filter_lua plugin
   will replace the original timestamp and record with the returned
   values. If code == 0 the original record is kept otherwise if
   code == -1, the original record will be deleted.
]] 


function mask_log_field(tag, timestamp, record)
    -- Record modified, so 'code' return value (first parameter) is 1
    local new_record = {}
    
    -- ログ出力
    -- io.stderr:write(record["field_2"].."\n")

    local mask_fields = split(record["mask_fields"], ",")
    
    for _, i in ipairs(mask_fields) do
        mask_field_array = split(i, "\\.")
        mask(record, mask_field_array)
    end
    return 1, timestamp, record
end
 
-- @see https://qiita.com/gp333/items/c472f7a7d9fcca1b5cb7
function split(str, ts)
    -- 引数がないときは空tableを返す
    if ts == nil then return {} end

    local t = {} ; 
    i=1
    for s in string.gmatch(str, "([^"..ts.."]+)") do
        t[i] = s
        i = i + 1
    end

    return t
end

function mask(record, mask_field_array)
    -- recordの内容は書き換えるため副作用が発生する
    -- 元のmask_field_arrayを書き換えないようにコピー
    local _mask_field_array = {unpack(mask_field_array)}
    if #_mask_field_array == 0 then
        return
    end
    

    local first_field = table.remove(_mask_field_array, 1)

    if #_mask_field_array == 0 then
        -- luaの文字列はシングルバイトを想定しているため文字列操作が困難なため固定文字列に置き換える
        record[first_field] = "xxxxx"
    else
        return mask(record[first_field], _mask_field_array)
    end
end
