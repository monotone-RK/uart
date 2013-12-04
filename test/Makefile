T=top

SRCS=test.v

TARGET=a.out
VCD=uut.vcd

IV=iverilog
GTK=gtkwave

$(T):
	$(IV) -o $(TARGET) $(SRCS)

run:
	vvp $(TARGET)

view:
	$(GTK) $(VCD) &

clean:
	rm -f $(TARGET) $(VCD)
