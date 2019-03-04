PYTHON ?= python
top_srcdir := `pwd`
PYTHONPATH ?= $(top_srcdir)
SUBDIRS = \
	$(top_srcdir)/doc \
	$(top_srcdir)/openal \
	$(top_srcdir)/openal/loaders \
	$(top_srcdir)/openal/test \
	$(top_srcdir)/openal/test/util \
	$(top_srcdir)/examples

INTERPRETERS = python2.7 python3.2 python3.3 pypy2.0


all: clean build

dist: clean docs
	@echo "Creating dist..."
	@$(PYTHON) setup.py sdist --format gztar
	@$(PYTHON) setup.py sdist --format zip

bdist: clean docs
	@echo "Creating bdist..."
	@$(PYTHON) setup.py bdist

build:
	@echo "Running build"
	@$(PYTHON) setup.py build
	@echo "Build finished, invoke 'make install' to install."


install:
	@echo "Installing..."
	@$(PYTHON) setup.py install

clean:
	@echo "Cleaning up in $(top_srcdir)/ ..."
	@rm -f *.cache *.core *~ MANIFEST *.pyc *.orig
	@rm -rf __pycache__
	@rm -rf build dist doc/html

	@for dir in $(SUBDIRS); do \
		if test -f $$dir/Makefile; then \
			make -C $$dir clean; \
		else \
			cd $$dir; \
			echo "Cleaning up in $$dir..."; \
			rm -f *~ *.cache *.core *.pyc *.orig *py.class; \
			rm -rf __pycache__; \
		fi \
	done

docs:
	@echo "Creating docs package"
	@rm -rf doc/html
	@cd doc && make html
	@mv doc/_build/html doc/html
	@rm -rf doc/_build
	@cd doc && make clean

release: dist

runtest:
	@PYTHONPATH=$(PYTHONPATH) $(PYTHON) -B -m openal.test.util.runtests


testall:
	@for interp in $(INTERPRETERS); do \
		PYTHONPATH=$(PYTHONPATH) $$interp -B -m openal.test.util.runtests; \
	done

# Do not run these in production environments! They are for testing
# purposes only!

buildall: clean
	@for interp in $(INTERPRETERS); do \
		$$interp setup.py build; \
	done


installall:
	@for interp in $(INTERPRETERS); do \
		$$interp setup.py install; \
	done


testpackage:
	@for interp in $(INTERPRETERS); do \
		$$interp -c "import openal.test; openal.test.run()"; \
	done

purge_installs:
	@for interp in $(INTERPRETERS); do \
		rm -rf /usr/local/lib/$$interp/site-packages/openal*; \
	done
