all: test/Makefile test/ape.mak test/ctpe.mak test/fifo.mak
	cd test && make -f ape.mak && make -f ctpe.mak && make -f fifo.mak && make

clean:
	cd test && rm *.vcd *.o ape cfar ctpe fifo *.xml

help:
	@echo "make       - ejecuación de pruebas y generación de waveforms"
	@echo "make clean - limpieza del área de trabajo"