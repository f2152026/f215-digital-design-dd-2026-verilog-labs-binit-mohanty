module tb;

  reg  [1:0] t_a, t_b;
  wire       t_gt, t_lt, t_eq;

  integer errors;
  integer i, j;
  integer onehot_count;

  comp2 DUT (
    .A  (t_a),
    .B  (t_b),
    .GT (t_gt),
    .LT (t_lt),
    .EQ (t_eq)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  initial begin
    errors = 0;

    for (i = 0; i < 4; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        t_a = i[1:0];
        t_b = j[1:0];
        #5; // let combinational logic settle

        onehot_count = t_gt + t_lt + t_eq;

        // Property 1: exactly one output should be high
        if (onehot_count != 1) begin
          $display("FAIL [one-hot]  A=%0d B=%0d -> GT=%b LT=%b EQ=%b  (sum=%0d, expected 1)",
                    t_a, t_b, t_gt, t_lt, t_eq, onehot_count);
          errors = errors + 1;
        end

        // Property 2: the high bit must be the correct one
        if (t_a > t_b && t_gt !== 1'b1) begin
          $display("FAIL [GT wrong] A=%0d B=%0d -> GT=%b (expected 1)", t_a, t_b, t_gt);
          errors = errors + 1;
        end
        if (t_a < t_b && t_lt !== 1'b1) begin
          $display("FAIL [LT wrong] A=%0d B=%0d -> LT=%b (expected 1)", t_a, t_b, t_lt);
          errors = errors + 1;
        end
        if (t_a == t_b && t_eq !== 1'b1) begin
          $display("FAIL [EQ wrong] A=%0d B=%0d -> EQ=%b (expected 1)", t_a, t_b, t_eq);
          errors = errors + 1;
        end
        if (t_a >= t_b && t_gt === 1'b1 && !(t_a > t_b)) begin
          // catches GT asserted when it should NOT be (e.g. A == B)
          $display("FAIL [GT spurious] A=%0d B=%0d -> GT=%b (expected 0)", t_a, t_b, t_gt);
          errors = errors + 1;
        end
      end
    end

    if (errors == 0)
      $display("ALL TESTS PASSED (16/16 input combinations correct)");
    else
      $display("%0d ERROR(S) FOUND", errors);

    $finish;
  end

  initial
    $monitor($time, " A=%0d B=%0d | GT=%b LT=%b EQ=%b", t_a, t_b, t_gt, t_lt, t_eq);

endmodule