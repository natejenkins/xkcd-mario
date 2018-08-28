# xkcd mario-ish
> A playable version of [xkcd 1110](https://xkcd.com/1110/)


## Game

Available [here](https://natejenkins.ch/xkcd)

## Development setup

Watch and build all coffee files:
```sh
coffee --watch  -o lib src/*
```

Run a server, for example hserver:

```
hserver
```

## Animations
I use Synfig and Pinta to create animations.  Synfig will render to a series of png files which need to be converted to a single strip of pngs (see files in `stick_figures` for examples).  To do this I use `montage`:

```
montage *.png -background none -tile 100x -geometry +0+0 output.png
```
The above command creates a single png with 100 frames.

## Meta

Nathan Jenkins – [@nathanjenkins12](https://twitter.com/nathanjenkins12) – nate.jenkins@gmail.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/natejenkins/xkcd-mario](https://github.com/natejenkins/xkcd-mario)

## Contributing

1. Fork it (<https://github.com/natejenkins/xkcd-mario/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request


## compiling coffeescript
`coffee --watch  -o lib src/*`

