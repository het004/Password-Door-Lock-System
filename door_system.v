module door_system( 
    input wire clk,            // Clock 
    input wire rst,            // Reset 
    input wire door_sensor,    // Door sensor input: 1 for locked, 0 for unlocked
    input wire passward_change, // Signal to change password 
    input wire [3:0] passward_input, // New password input (4-bit) 
    output reg correct_passward, // Output indicating if the password is correct 
    output reg wrong_passward,   // Output indicating if the password is wrong 
    output reg door_locked       // Output indicating if the door is locked (1 for locked, 0 for unlocked)
);

    // Internal registers for password storage and mode tracking
    reg [3:0] passward = 4'b1111; // Default password: '1111'
    reg [1:0] mode = 2'b00;       // Default mode: door lock mode

    // Sequential logic: triggered on clock or reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset system to default values
            passward <= 4'b1111;      // Reset password to '1111'
            mode <= 2'b00;            // Reset mode to door lock
            door_locked <= 1'b1;      // Lock the door by default
        end else begin
            case (mode)
                // Door lock mode
                2'b00: begin
                    door_locked <= 1'b1; // Ensure door is locked
                    if (door_sensor == 1 && passward_input == passward) begin
                        mode <= 2'b01;  // Switch to door unlock mode if password is correct
                        door_locked <= 1'b0;  // Unlock the door
                        correct_passward <= 1'b1;
                        wrong_passward <= 1'b0;
                    end else if (door_sensor == 1 && passward_input != passward) begin
                        wrong_passward <= 1'b1;
                        correct_passward <= 1'b0;
                    end
                end

                // Door unlock mode
                2'b01: begin
                    door_locked <= 1'b0; // Ensure door is unlocked
                    if (door_sensor == 0 && passward_input == passward) begin
                        mode <= 2'b00;  // Return to door lock mode
                        door_locked <= 1'b1; // Lock the door
                        correct_passward <= 1'b1;
                        wrong_passward <= 1'b0;
                    end else if (door_sensor == 1 && passward_input != passward) begin
                        mode <= 2'b01; // Remain in unlock mode if password is incorrect
                        wrong_passward <= 1'b1;
                        correct_passward <= 1'b0;
                    end
                end

                // Password change mode
                2'b10: begin
                    passward <= passward_input;  // Update the password
                    mode <= 2'b00;               // Return to door lock mode
                end

                default: begin
                    mode <= 2'b00;  // Default to door lock mode
                end
            endcase
        end
    end
endmodule
