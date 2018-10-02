// Adder circuit

`define AND and #50
`define OR or #50
`define NOT not #50
`define XOR xor #50

`define ADD  3'd0
`define SUB  3'd1
`define XOR  3'd2
`define SLT  3'd3
`define AND  3'd4
`define NAND 3'd5
`define NOR  3'd6
`define OR   3'd7


module ALUcontrolLUT
(
output reg	address0,
output reg	address1,
output reg invert,
input[2:0]	ALUcommand
)

  always @(ALUcommand) begin
    case (ALUcommand)
      `ADD:  begin address0 = 0; address1=0; invert = 0; end
      `SUB:  begin address0 = 0; address1=0; invert = 1; end
      `XOR:  begin address0 = 1; address1=1; invert = 0; end
      `SLT:  begin address0 = 0; address1=0; invert = 1; end
      `AND:  begin address0 = 0; address1=1; invert = 0; end
      `NAND: begin address0 = 0; address1=1; invert = 1; end
      `NOR:  begin address0 = 1; address1=0; invert = 1; end
      `OR:   begin address0 = 1; address1=0; invert = 0; end
    endcase
  end
endmodule

module structuralMultiplexer
(
    output out,
    input address0, address1,
    input in0, in1, in2, in3
);
    wire notA0, notA1, notA0andnotA1, notA0andA1, A0andnotA1, A0andA1;
    wire in0and, in1and, in2and, in3and;
    `NOT not1(notA0, address0);
    `NOT not2(notA1, address1);
    `AND and1(A0andA1, address0, address1);
    `AND and2(A0andnotA1, address0, notA1);
    `AND and3(notA0andA1, notA0, address1);
    `AND and4(notA0andnotA1, notA0, notA1);
    `AND and5(in0and, in0, notA0andnotA1);
    `AND and6(in1and, in1, A0andnotA1);
    `AND and7(in2and, in2, notA0andA1);
    `AND and8(in3and, in3, A0andA1);
    `OR or1(out, in0and, in1and, in2and, in3and);

endmodule

module structuralBitSlice
(
    output sum,
    output carryout,
    input[2:0] control,
    input a,
    input b,
    input carryin

);

 wire AxorB2, AxorBxorC, AxorBC, AB, notControl1, notControl2, subtract, newB;
 wire sumval, address0, address1, invert, nandand, noror, AxorB, AorB;
 ALUcontrolLUT mylut(address0, address1, invert, control);

 // values for sum, subtract, and slt
 'NOT notGate(notControl1, control[1]);
 'NOT notGate2(notControl2, control[2]);
 'AND andGate(subtract, control[0], notControl1, notControl2);
 'XOR xorGate(newB, subtract, b);
 `XOR xorGate1(AxorB2, a, newB);
 `XOR xorGate2(sumval, AxorB2, carryin);
 `AND andGate1(AB, a, b);
 `AND andGate2(AxorBC, carryin, AxorB2);
 `OR orGate( carryout, AB, AxorBC);

 // values for or and nor
 'OR orGate(AorB, a, b);
 'XOR xorGate4(noror, invert, AorB);

 // values for and and nand
'XOR xorGate3(nandand, invert, AB);

// value for xor
'XOR xorGate5(AxorB, a, b);

 structuralMultiplexer mymux(sum, address0, address1, sumval, noror, nandand, AxorB);



endmodule
