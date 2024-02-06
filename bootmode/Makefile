%.o: %.S
	dir=`mktemp -d`; cp -t $$dir $^; \
	podman run -v $$dir/:/build/:Z --rm -it h8500-as:latest /bin/bash -c "cd /build/; as -o $@ $<" && cp $$dir/$@ $@; \
	rm -r $$dir;

%.out: %.o
	dir=`mktemp -d`; cp -t $$dir $^; \
	podman run -v $$dir/:/build/:Z --rm -it h8500-as:latest /bin/bash -c "cd /build/; ld --oformat binary -o $@ $<" && cp $$dir/$@ $@; \
	rm -r $$dir;
