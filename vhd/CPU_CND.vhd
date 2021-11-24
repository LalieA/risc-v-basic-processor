library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        rs1         : in w32;
        alu_y       : in w32;
        IR          : in w32;
        slt         : out std_logic;
        jcond       : out std_logic
    );
end entity;

architecture RTL of CPU_CND is
    signal sign_ext : std_logic;
    signal x_ext : signed(32 downto 0);
    signal y_ext : signed(32 downto 0);
    signal res : signed(32 downto 0);
    signal s   : std_logic;
    signal z   : std_logic;
begin
    sign_ext <= (
        (not IR(12) and not IR(6))
        or
        (not IR(13) and IR(6))
    );

    x_ext <= (rs1(31) & signed(rs1)) when sign_ext = '1' else ("0" & signed(rs1));
    y_ext <= (alu_y(31) & signed(alu_y)) when sign_ext = '1' else ("0" & signed(alu_y));

    res <= x_ext - y_ext;
    z <= '1' when res = (res'range => '0') else '0';
    s <= res(32);

    jcond <= (
        (not IR(14) and (IR(12) xor z))
        or
        (IR(14) and (IR(12) xor s))
    );
    slt <= s;
end architecture;
