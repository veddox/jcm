# Project details

*JCM: a simple forest model to explore the Janzen-Connell effect.*

## Author

**Daniel Vedder**  
Ecosystem Modeling Group  
Center for Computational and Theoretical Biology  
University of Würzburg  
[daniel.vedder@stud-mail.uni-wuerzburg.de](mailto:daniel.vedder@stud-mail.uni-wuerzburg.de)

## Releases

- **v1.0-rc1** Basic forest model with dispersal, growth, and competition submodels.

- **v1.0-rc2** Adds infection submodel.

- **v1.0-rc3 [current]** Adds variable species.

- **v1.0** Finished version, including the scripted experiment.

## TODO

### Bugs

- trees randomly die after world initialisation?

- `forest.jl`, line 107: `sqrt()` was called with an argument of -32768.0?

### Features

- implement proper (or at least, linear) dispersal kernels for seeds

## License

Licensed under the terms of the MIT license:

```
Copyright (c) 2020 Daniel Vedder

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
