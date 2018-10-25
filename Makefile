NAME := "ansible-provision"
VERSION := $(shell git tag --points-at HEAD )

ifdef VERSION
else
  VERSION := $(shell git describe --abbrev=0 --tags)-debug
endif

.PHONY: docs
docs:
	pip install mkdocs mkdocs-material pymdown-extensions Pygments
	git remote add docs "https://$(GH_TOKEN)@github.com/moshloop/ansible-provision.git"
	git fetch docs && git fetch docs gh-pages:gh-pages
	mkdocs gh-deploy -v --remote-name docs

.PHONY: package
package:
	pip install twine
	python setup.py sdist
	twine upload dist/*.tar.gz || echo already exists
	$(shell rm *.rpm || true)
	$(shell rm *.deb || true)
	docker run --rm -it -v $(CURDIR):$(CURDIR) -w $(CURDIR) alanfranz/fpm-within-docker:ubuntu-xenial fpm  -s dir -t deb -n $(NAME) -v $(VERSION) -x "*.DS_Store"/ -x ".git" ./=/etc/ansible/roles/provision
	mv *.deb $(NAME).deb
	docker run --rm -it -v $(CURDIR):$(CURDIR) -w $(CURDIR) alanfranz/fpm-within-docker:centos-7 fpm  -s dir -t rpm -n $(NAME) -v $(VERSION) -x "*.DS_Store" -x ".git" ./=/etc/ansible/roles/provision
	mv *.rpm $(NAME).rpm

.PHONY: setup
setup:
	pip install ansible-run==3.3

.PHONY: test
test: setup
	ENTRYPOINT=bash ansible-run ./tests/test.sh $(test) -v