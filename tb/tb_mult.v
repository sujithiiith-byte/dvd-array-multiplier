//testbench for mult_array: exhaustive and self-checking
`timescale 1ns/1ps
module tb_mult;

reg clk, rst_n;
reg [3:0] a, b;
wire [7:0] p;
reg [7:0] expected;   //a*b for the current vector (shown in the waveform)

integer i, j, errors;
integer prev;   //value p held after the previous vector (0 after reset)

mult_array dut (
    .clk(clk),
    .rst_n(rst_n),
    .a(a),
    .b(b),
    .p(p)
);

//10 ns clock
always #5 clk = ~clk;

initial begin
    $dumpfile("mult.vcd");
    $dumpvars(0, tb_mult);

    clk = 0; rst_n = 0; a = 0; b = 0; errors = 0; prev = 0; expected = 0;

    //hold reset low for the first 2 cycles
    repeat (2) @(posedge clk);
    @(negedge clk) rst_n = 1;

    //all 256 combinations
    //inputs are driven and p is sampled on the falling edge, half a cycle away
    //from the rising edge, so there is no race with the flip-flops (also in the
    //gate-level simulation, where each flip-flop has a 1 ns clock-to-q delay)
    for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            //we are on a falling edge here: apply the new inputs
            a = i;
            b = j;
            expected = i * j;

            //rising edge 1 loads a_reg/b_reg only: p must not change yet
            @(negedge clk);
            if (p !== prev) begin
                $display("MISMATCH (latency): a=%0d b=%0d p=%0d after 1 cycle, expected unchanged %0d", a, b, p, prev);
                errors = errors + 1;
            end

            //rising edge 2 loads p: now it must be the new product
            @(negedge clk);
            prev = p;

            if (p !== expected) begin
                $display("MISMATCH: a=%0d b=%0d p=%0d expected=%0d", a, b, p, expected);
                errors = errors + 1;
            end
        end
    end

    if (errors == 0)
        $display("PASS: 256 vectors checked, 0 errors");
    else
        $display("FAIL: 256 vectors checked, %0d errors", errors);

    $finish;
end

endmodule
