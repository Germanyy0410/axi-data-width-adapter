task automatic c1;
  begin
      @(posedge aclk);
      #0.1;
  end
endtask

task automatic c2;
  begin
    @(negedge aclk);
    #0.1;
  end
endtask

task automatic c3;
  begin
    #0.1;
  end
endtask