# Wakame

Wakame is a Crystal binding for MeCab([Website](https://taku910.github.io/mecab)/[Wikipedia](https://en.wikipedia.org/wiki/MeCab)), a morphological analyzer written in C++ often used to analyze Japanese texts. Wakame aims to provide natural interfaces to MeCab in Crystal.

This project is currently work-in-progress. While Wakame's internal direct binding to C has 100% coverage of the original C interfaces, it's currently lacking with higher-level abstractions in Crystal.

## Dependencies

- [MeCab](https://taku910.github.io/mecab/#download)
  - You may also need to install `libmecab-dev` if you are installing from the package manager.
- One of the system dictionaries available on the [website](https://taku910.github.io/mecab/#download) or a third-party dictionary like [mecab-ipadic-NEologd](https://github.com/neologd/mecab-ipadic-neologd)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     wakame:
       github: soya-daizu/wakame
   ```

2. Run `shards install`

## Usage

An example of usage through Wakame's internal direct binding to C is available under the `examples/` directory. More guides will be added after Wakame supports higher-level abstractions.

## Contributing

1. Fork it (<https://github.com/soya-daizu/wakame/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [soya_daizu](https://github.com/soya-daizu) - creator and maintainer
