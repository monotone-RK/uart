
# ----- SRCS and TARGET setting ----- #
# T    : src file name you want to test
# PRE  : test bench prefix (Write test bench file like test_hoge.v)
# POST : filename extension
T=uart
PRE=tb_
POST=.v

SRCS=$(PRE)$(T)$(POST)
TARGET=$(PRE)$(T)

# ----- Log files setting ----- #
# LOG  : simulation result (text, Verilog)
# VCD  : simulation result (wave, Verilog)
SOFT=good.txt
LOG=log.txt
VCD=uut.vcd

# ----- iverilog setting ----- #
IV=iverilog -I ../src/ -o $(TARGET) $(SRCS)

# ----- gtkwave setting ----- #
GTK=gtkwave $(VCD) &


iverilog:
	$(IV)

run:
	./$(TARGET)

dump:
	./$(TARGET) > $(LOG)

view:
	$(GTK)

clean:
	rm -f $(TARGET) $(VCD) $(LOG)

