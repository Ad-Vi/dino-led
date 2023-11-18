library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all;

entity display is
  port 
  (  -- input ports
  clk0                  : in std_logic; -- quicker clock
  clk1                  : in std_logic; -- slower clock
  but_Jump              : in std_logic; -- Jump button 
  but_Crouch            : in std_logic; -- Crouch button
  but_Reset             : in std_logic; -- Reset button
  
   -- output ports
  led_play              : out std_logic; -- led saying that we play
  led_lost              : out std_logic; -- led saying that we lost the game 
  led_reset             : out std_logic; -- led saying that we reset the game
  columns               : out std_logic_vector(0 to 6) ;  -- Led matrix
  column_red            : out std_logic_vector(0 to 4) ;  -- Led matrix
  column_yel            : out std_logic_vector(0 to 4) ;  -- Led matrix
  score                 : out std_logic_vector(0 to 7) ); -- nbr of obstacle avoid
end entity display ;

architecture display_arch of display is
   
  signal cur_col     : integer range 0 to 6 := 0;             
    -- curent column displayed by display
  signal vector_r    : std_logic_vector(0 to 4) := "11111";   
    -- vector of red leds (0 = lit ) 
  signal vector_y    : std_logic_vector(0 to 4) := "00011";   
    -- vector of yellow leds
  signal jmp_cnt     : integer range 0 to 40 := 0;            
    -- counter of jumps 
  signal lost        : std_logic := '0';                      
    -- saying that we have lost
  signal random      : integer range 0 to 7 := 7;             
    -- random generated integer
  signal obst_pos    : integer range 0 to 6 := 0;             
    -- position of the obstacle on the column
  signal obst_cnt    : integer range 0 to 10 := 0;            
    -- count of obsatble 
  signal nb_obst     : integer range 0 to 255 := 0;           
    -- number of obstacle generated
             
  begin
    game : process( clk1 )
    begin
      if( rising_edge( clk1 ) ) then
        
        if (lost = '0') then -- Game is on 
          led_play <= '1';
          led_lost <= '0';
          led_reset <= '0';
              
        -- JUMP BUTTON
        if (jmp_cnt = 0) then
          if (but_Jump = '1') then 
            random <= cur_col;  -- compute the random number
             
            -- display the player in the 3 uppper leds (we jump)
            jmp_cnt <= 40;
            vector_y <= "11000";
          end if ; 
        else
          if (jmp_cnt = 1) then
            vector_y <= "00011";
          end if ;
          jmp_cnt <= jmp_cnt - 1;
        end if ;
        
        if (but_Crouch = '1') then
          random <= cur_col;  -- compute the random number
          
          if (jmp_cnt /= 0) then
            jmp_cnt <= 1;
          end if ;
          
          vector_y(2) <= '1'; -- turn off the 3rd upper led
        else
          vector_y(2) <= '0';
        end if ;
        
        -- OBSTACLE MOVE AND GESTION
        if (obst_cnt = 0) then
          obst_cnt <= 10;
                 
          -- we generate a new obstacle when the previous one has cross the matrix
          if (obst_pos = 6) then
            obst_pos <= 0;
                    
          -- different obstacles
              case random is
                when 0 => vector_r <= "00111";
                when 1 => vector_r <= "01111";
                when 2 => vector_r <= "11011";
                when 3 => vector_r <= "11001";
                when 4 => vector_r <= "11110";
                when 5 => vector_r <= "11101";
                when 6 => vector_r <= "10111";
                when 7 => vector_r <= "11100"; -- should not happend
              end case ;
              
              random <= 7; 
              nb_obst <= nb_obst + 1 ;
              score <= std_logic_vector(to_unsigned(nb_obst, score'length));
            else
              obst_pos <= obst_pos + 1;
            end if ;
          else
            obst_cnt <= obst_cnt - 1;
          end if;
          
                          
          -- CHECK IF WE HIT AN OBSTACLE
          if (obst_pos = 5) then
            for r in 0 to 4 loop
              if (vector_y(r) = '0' and vector_r(r) = '0') then
                lost <= '1';
                vector_y <= "11111";
                vector_r <= "00000";
              end if ;
            end loop ;
          end if ;
        else
         led_play <= '0';
         led_lost <= '1';
        end if ; -- end if (lost = '0')
        
        if (but_Reset = '1') then
          lost <= '0';
          score <= "00000000";
          nb_obst <= 0;
          obst_cnt <= 0;
          jmp_cnt <= 0;
           
          vector_y <= "00011";
          vector_r <= "11111";
          led_reset <= '1';
          led_play <= '0';
        end if ;
        
        -- RANDOM NUMBER GENERATION IF WE DON4T TOUCH BUTTONS
        if (random = 7) then
          random <= cur_col;
        end if ;
      end if ;
    end process game ;
                  
    -- DISPLAY THE LED MATRIX
    display : process ( clk0 ) -- clk0 : quicker clock
    begin
      if ( rising_edge( clk0 ) ) then

    	 if (cur_col = 6) then
          cur_col <= 0 ;
        else
          cur_col <= cur_col + 1 ;
        end if ;

        if (cur_col = 5) then
          column_yel <= vector_y;
        else
          column_yel <= "11111";
        end if ;

        if (cur_col = obst_pos) then
          column_red <= vector_r;
        else
          column_red <= "11111";
        end if ;

        case cur_col is
          when 0 => columns <= "1000000" ;
          when 1 => columns <= "0100000" ;
          when 2 => columns <= "0010000" ;
          when 3 => columns <= "0001000" ;
          when 4 => columns <= "0000100" ;
          when 5 => columns <= "0000010" ;
          when 6 => columns <= "0000001" ;
        end case ;


      end if ;

  end process display ;
    
end architecture display_arch ;