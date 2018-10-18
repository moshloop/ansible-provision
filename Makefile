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
	pip install https://files.pythonhosted.org/packages/3f/1c/00c8ab957f5eae32a6e1750522be9231e19cffac9e970b09091fba909cc1/ansible-deploy-1.6.2.tar.gz
	./tests/test.sh $(test) -v