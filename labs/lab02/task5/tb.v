module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  reg  [3:0] expected;
  integer errors;
  integer tests;

  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  task check(input string label);
    begin
      #1; // allow combinational logic to settle
      expected = t_op ? (t_a - t_b) : (t_a + t_b);
      tests = tests + 1;
      if (t_result !== expected) begin
        $display("FAIL [%s]: a=%0d b=%0d op=%0d -> result=%0d (expected %0d)",
                  label, t_a, t_b, t_op, t_result, expected);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    errors = 0;
    tests  = 0;

    // --- Directed: flip ONLY op, a/b held constant ---
    t_a = 4'd9; t_b = 4'd3; t_op = 1'b0;
    #5 check("op-toggle-1a");
    t_op = 1'b1;                 // a, b unchanged
    #5 check("op-toggle-1b");

    t_a = 4'd2; t_b = 4'd7; t_op = 1'b1;
    #5 check("op-toggle-2a");
    t_op = 1'b0;                 // a, b unchanged
    #5 check("op-toggle-2b");

    // --- Exhaustive sweep over a, b, op ---
    for (int i = 0; i < 16; i = i + 1) begin
      for (int j = 0; j < 16; j = j + 1) begin
        t_a = i[3:0]; t_b = j[3:0]; t_op = 1'b0;
        #5 check("sweep-add");
        t_a = i[3:0]; t_b = j[3:0]; t_op = 1'b1;
        #5 check("sweep-sub");
      end
    end

    if (errors == 0)
      $display("ALL TESTS PASSED (%0d/%0d)", tests, tests);
    else
      $display("%0d/%0d TEST(S) FAILED", errors, tests);

    $finish;
  end

endmodule