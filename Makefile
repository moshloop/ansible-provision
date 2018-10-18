docs:
	pip install mkdocs mkdocs-material pymdown-extensions Pygments twine
	git remote add docs "https://$(GH_TOKEN)@github.com/moshloop/ansible-provision.git"
	git fetch docs && git fetch docs gh-pages:gh-pages
	mkdocs gh-deploy -v --remote-name docs
	python setup.py sdist
	twine upload dist/*.tar.gz || echo already exists

ssh-key:
	mkdir -p ~/.ssh
	ssh-keygen -f ~/.ssh/id_rsa -N ""

setup: ssh-key
	pip install ansible-run

test: setup
	pip install https://files.pythonhosted.org/packages/fa/0f/6ce0cfc5fbf7051f7fd378d55ae0fa3c877abe2e0b0cd47c267e6fc43bf1/ansible-deploy-2.1.tar.gz
	./tests/test.sh $(test) -v