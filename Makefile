.PHONY: docs windows clean clean-windows

default: windows
	@true

clean: lean-windows
	@true

windows: clean-windows
	./build $(DOCKER_BUILD_FLAGS) $(INNO_FLAGS)

clean-windows:
	rm -f dist/SageMath*

docs:
	$(MAKE) -C docs docs
