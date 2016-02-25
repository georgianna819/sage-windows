.PHONY: docs windows clean clean-windows

default: windows
	@true

clean: lean-windows
	@true

windows: clean-windows
	./build

clean-windows:
	rm -f dist/SageMath*

docs:
	$(MAKE) -C docs docs
