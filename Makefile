NAME := "ansible-provision"
VERSION := $(shell git tag --points-at HEAD )

ifdef VERSION
else
  VERSION := $(shell git describe --abbrev=0 --tags)-debug
endif

docs:
	pip install mkdocs mkdocs-material pymdown-extensions Pygments twine
	git remote add docs "https://$(GH_TOKEN)@github.com/moshloop/ansible-provision.git"
	git fetch docs && git fetch docs gh-pages:gh-pages
	mkdocs gh-deploy -v --remote-name docs
	python setup.py sdist
	twine upload dist/*.tar.gz || echo already exists


.PHONY: package
package:
	$(shell rm *.rpm || true)
	$(shell rm *.deb || true)
	docker run --rm -it -v $(CURDIR):$(CURDIR) -w $(CURDIR) alanfranz/fpm-within-docker:ubuntu-xenial fpm  -s dir -t deb -n $(NAME) -v $(VERSION) -x "*.DS_Store"/ -x ".git" ./=/etc/ansible/roles/provision
	mv *.deb $(NAME).deb
	docker run --rm -it -v $(CURDIR):$(CURDIR) -w $(CURDIR) alanfranz/fpm-within-docker:centos-7 fpm  -s dir -t rpm -n $(NAME) -v $(VERSION) -x "*.DS_Store" -x ".git" ./=/etc/ansible/roles/provision
	mv *.rpm $(NAME).rpm

ssh-key:
	mkdir -p ~/.ssh
	ssh-keygen -f ~/.ssh/id_rsa -N ""

setup: ssh-key
	pip install ansible-run

test: setup
	sudo pip install https://files.pythonhosted.org/packages/30/ef/c56b6b0171882d00d108566244a25a23ef628ef35b1401c55b960e0573e1/ansible-extras-1.0.3.tar.gz
	sudo pip install https://files.pythonhosted.org/packages/fa/0f/6ce0cfc5fbf7051f7fd378d55ae0fa3c877abe2e0b0cd47c267e6fc43bf1/ansible-deploy-2.1.tar.gz
	./tests/test.sh $(test) -v