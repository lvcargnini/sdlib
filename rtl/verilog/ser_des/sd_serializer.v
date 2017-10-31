//----------------------------------------------------------------------
// Author: Frank Wang
// 
// Serialize wider parallel data into narrower data in multiple cycles.
//
//----------------------------------------------------------------------
//
// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.
//
// In jurisdictions that recognize copyright laws, the author or authors
// of this software dedicate any and all copyright interest in the
// software to the public domain. We make this dedication for the benefit
// of the public at large and to the detriment of our heirs and
// successors. We intend this dedication to be an overt act of
// relinquishment in perpetuity of all present and future rights to this
// software under copyright law.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
// OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// For more information, please refer to <http://unlicense.org/> 
//----------------------------------------------------------------------
`ifndef _SD_SERIALIZER_V_
`define _SD_SERIALIZER_V_
module sd_serializer #(
    parameter int PARA_WIDTH=63,
    parameter int SER_WIDTH=8,
    parameter int NUM_SEG=((PARA_WIDTH/SER_WIDTH)*SER_WIDTH == PARA_WIDTH) ? PARA_WIDTH/SER_WIDTH : PARA_WIDTH/SER_WIDTH+1,
    parameter int SEG_SZ=$clog2(NUM_SEG)
) (
    input   logic [PARA_WIDTH-1:0] c_data,
    input   logic [SEG_SZ-1:0]     c_ms_seg, //most-significant data segments that is valid, must be between 0 and NUM_SEG-1
    input   logic                  c_srdy,
    output  logic                  c_drdy,

    output  logic [SER_WIDTH-1:0] p_data,
    output  logic                 p_ef,
    output  logic                 p_srdy,
    input   logic                 p_drdy,

    input   clk,
    input   reset
);

//localparam NUM_SEG_FLOOR = (PARA_WIDTH/SER_WIDTH);
//localparam NUM_SEG=(NUM_SEG_FLOOR*SER_WIDTH == PARA_WIDTH) ? NUM_SEG_FLOOR : NUM_SEG_FLOOR+1;
//localparam LAST_SEG_WIDTH = (NUM_SEG_FLOOR*SER_WIDTH == PARA_WIDTH) ? SER_WIDTH : (PARA_WIDTH - NUM_SEG_FLOOR*SER_WIDTH);
//localparam SEG_SZ = $clog2(NUM_SEG);

logic [SEG_SZ-1:0]  st_seg_num;
logic [SEG_SZ-1:0]  cur_seg_num;

assign c_drdy = (cur_seg_num == c_ms_seg) && p_drdy;
assign p_ef   = (cur_seg_num == c_ms_seg);
assign p_srdy = c_srdy;
assign p_data = c_data >> (cur_seg_num * SER_WIDTH);
always @(*) begin
    cur_seg_num = st_seg_num;
    if(p_srdy && p_drdy) begin
        cur_seg_num = st_seg_num + 1'b1;
        if(cur_seg_num > c_ms_seg) cur_seg_num = {SEG_SZ{1'b0}};
    end
end
always @(posedge clk) begin
    st_seg_num <= cur_seg_num;
    if(reset) st_seg_num <= NUM_SEG-1;
end

endmodule 
// Local Variables:
// End:
`endif //  _SD_SERIALIZER_V_
