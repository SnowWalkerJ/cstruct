.phony: clean build test benchmark

clean:
	rm -f **/*.so >/dev/null || true
	rm -f **/*.c >/dev/null || true
	rm -f -r build >/dev/null || true
	rm -f -r dist >/dev/null || true
	rm -f -r cstruct.egg-info >/dev/null || true
	rm -f **/*.html >/dev/null || true

build:
	python setup.py build_ext --inplace

test:
	python -m unittest discover -s tests

benchmark:
	python benchmark.py
