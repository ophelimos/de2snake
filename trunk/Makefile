################################################################################
# Makefile for DE1/2 Microprocessor Labs
# Peter Yiannacouras, December 6, 2007
#
# You can change the variables below to match your environment, or you can
# override them at the command line.
################################################################################

SETUPPATH=X:/ECE/MSL/NIOSII/shell_v2.4.2/setup

# NIOS2EDSPATH should resemble C:/altera/71/nios2eds, variable SOPC_KIT_NIOS2 
# holds this path, so we get it from there.
NIOS2EDSPATH=${SOPC_KIT_NIOS2}
CABLE=USB-Blaster[USB-0] 

SRCS=snake_main.c get_pixel.s init_keyboard init_timer.s init_vga.s playwav.s put_pixel.s randomvalue.s reverse_game_over.s getch.s LCD_Function.s draw_border.s init_pushbuttons.s
TARGET=prog

SYMBOLNAME=yoursymbolname

SOF=${SETUPPATH}/DE2_NIOS2_System_v2.4.2.sof
DE1SOF=${SETUPPATH}/DE1_NIOS2_System_v2.4.2.sof
######################  Do not modify anything below here #################
OBJS=$(addsuffix .o, $(basename ${SRCS}))

default: help

compile: $(TARGET).elf
$(TARGET).elf: ${OBJS} crt0.o force
	nios2-elf-ld --defsym nasys_stack_top=0x17fff80 --defsym nasys_program_mem=0x1000000 --defsym nasys_data_mem=0x1000000 --section-start .exceptions=0x1000020 --section-start .reset=0x1000000 -e _start -u _start --script=${SETUPPATH}/nios_cpp_build.ld -L$(NIOS2EDSPATH)/bin/nios2-gnutools/H-i686-pc-cygwin/lib/gcc/nios2-elf/3.4.1 -L$(NIOS2EDSPATH)/bin/nios2-gnutools/H-i686-pc-cygwin/nios2-elf/lib -L${SETUPPATH} -g -o $(TARGET).elf ${OBJS} crt0.o -lUP -lc -lgcc -lg -lMSL -lnosys
	@echo
	@tail -`date +%S |cut -c2` ${SETUPPATH}/tips.txt |head -1
	@echo

#Phony target for forcing things to happen
force:  

crt0.o: ${SETUPPATH}/crt0.s
	nios2-elf-as --gstabs -I $(NIOS2EDSPATH)/components/altera_nios2/sdk/inc -I${SETUPPATH}/include $? -o $*.o 

%.o:  %.s
	nios2-elf-as --gstabs -I $(NIOS2EDSPATH)/components/altera_nios2/sdk/inc -I${SETUPPATH}/include $? -o $*.o 

srec: $(TARGET).srec
$(TARGET).srec:  $(TARGET).elf
	nios2-elf-objcopy -O srec $(TARGET).elf $(TARGET).srec 

%.o:  %.c 
	nios2-elf-gcc -g -mno-cache-volatile -mno-hw-mulx -mhw-mul -mhw-div -O1 -ffunction-sections -fdata-sections -fverbose-asm -fno-inline -I${SETUPPATH}/include -I$(NIOS2EDSPATH)/components/altera_nios2/HAL/inc -DSYSTEM_BUS_WIDTH=32 -DALT_SINGLE_THREADED -D_JTAG_UART_BASE=0x00ff10f0 -c $?

disasm: $(TARGET).elf
	nios2-elf-objdump -D $(TARGET).elf |less

run: $(TARGET).elf
	nios2-download --cable $(CABLE) $(TARGET).elf -g

debug: $(TARGET).srec
	nios2-gdb-server --cable=$(CABLE) --stop --tcpport=2342 $(TARGET).srec &
	nios2-elf-insight $(TARGET).elf --command=${SETUPPATH}/setup.gdb

debugcmdline: $(TARGET).srec
	nios2-gdb-server --cable=$(CABLE) --stop --tcpport=2342 $(TARGET).srec &
	nios2-elf-gdb $(TARGET).elf --command=${SETUPPATH}/setup.gdb

findsymbol: $(TARGET).elf
	@echo
	nios2-elf-nm $(TARGET).elf |grep $(SYMBOLNAME)

#Occasionally the debugger won't start up, it will freeze with no window 
#To fix this just delete the configuration file
resetdebugger:
	rm -f "${HOME}/gdbtk.ini"

test: maketest terminal

maketest:
	cp $(SETUPPATH)/test.elf ./__test.elf
	nios2-download --cable $(CABLE) ./__test.elf -g
	rm -f __test.elf

terminal:
	nios2-terminal --cable $(CABLE)

configure:
	nios2-configure-sof --cable $(CABLE) $(SOF)
de1configure:
	nios2-configure-sof --cable $(CABLE) $(DE1SOF)

clean:
	rm -f *.srec *.elf *.o

help:
	@echo
	@echo Usage: 'make [SRCS="file1 file2 ..."] [SYMBOLNAME=sym] action'
	@echo
	@echo '  fileN  - can be any assembly (.s) or C (.c) file, mixing is allowed'
	@echo
	@echo '  sym    - The name of the symbol you want to find'
	@echo
	@echo '  action - can be any of the following actions:'
	@echo '           configure    : Configures the DE2 hardware system (do this once)'
	@echo '           de1configure : Configures the DE1 hardware system (do this once)'
	@echo '           compile      : Compiles all SRCS files to a single program'
	@echo '           run          : Compiles and runs the program on the DE1/2 board'
	@echo '           debug        : Compiles, and opens the debugger'
	@echo '           disasm       : Disassembles the program'
	@echo '           findsymbol   : Find the address of the symbol SYMBOLNAME'
	@echo '           terminal     : Starts the JTAG UART terminal'
	@echo
	@echo Example 1.  I want to run myprog.s
	@echo '   Type: make SRCS=myprog.s run'
	@echo
	@echo Example 2.  I want to debug my program which is made of two files main.c foo.s
	@echo '   Type: make SRCS="main.c foo.s" debug'

# Used for emacs' flymake syntax checker
#check-syntax:
#	$(CC) -DCACHING_ON -Wall -Wextra -fsyntax-only $(CHK_SOURCES)

.PHONY: disasm run configure de1configure clean gcc default debug help compile terminal test srec force findsymbol resetdebugger maketest terminal
