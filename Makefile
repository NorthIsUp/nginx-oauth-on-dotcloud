local:
	./nginx/builder
	./postinstall

push:
	dotcloud push

clean:
	./nginx/builder -c
