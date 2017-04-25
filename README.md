# HP12C Parser

It's a simple parser that works like HP12C Financial Calculator.

Current implementation covers basically x,y,z registers and storage:

Basic operations like:

```ruby
1
2
+ # => 3
```

See the code and examples.

```ruby
1
2
+ # 3
+ # 5
```

```ruby
1
2
+ # 3
5
+ # 8
```

## sto for storage

Use `sto <num>` to storage the x register on a memory with the index specified on `num`.

```ruby
1234
sto 1
rcl 1 # 1234

10
sto 1
20
sto 2
30
sto 3
rcl 1 # 10
rcl 2 # 20
rcl 3 # 30
```

## rcl for recover from memory storage

As the example below, `sto` command stores the `X` and `rcl` recovers from that.

You can make operations bringing storage through `rcl <num>` command.

Where `<num>` is the same memory index used with `sto <num>` to get the value back.

```
123
sto 1
456
sto 2
rcl 2
rcl 1
- # 333
```
