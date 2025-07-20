# jselect - overengineered grep for json

We are using semantic logging and everything is coming out as JSON, it's really nice and can be fed into all sorts of scripts to summarise activity or identify issues. What It's not good at is quick explorations. `grep` sort of works but complex queries can be a pain to implement, you just end up writing tons of little programs to get things done

So inspired by the query language available in AWS Cloudwatch I wrote my own, Behold:

```bash
$ jselect '.level = "error"' output_8.txt
```

This will parse the contents of `output_8.txt` and where the data is `{ ... "level":"error", ... }` it will output all the lines that have `"level":"error"`

```bash
$ jselect '.level = "error" || .payload.sequence_error = true' output_8.txt
```

You get the idea. The system handles all the various JSON data types, `true`, `false`, `null`, strings, integers and floats. You cannot do queries with arrays yet, not quite worked out how that would actually work

## Spreadsheet logic

Here's an example `.level = null` what we are asking for here is that the `"level"` key in the hash contains the value `null`. But what if the key `"level"` does not exist? In a normal programming language this would be an exception of some sort or perhaps it will fudge a default return value. It is hardly helpful for our script to crash so when it does something like `1 < 2`, it returns two things. First the fact that the `<` worked without error and then the result of `<` itself. So **true** and **true**

But what about `"error" < 2`? Again a normal programming language you would get an exception, here we will return **false** and **null**. The **false** indicates that the `<` failed to run correctly and the **null** is really just a placeholder as there is no realistic value that can be returned. The program can run without crashing

So `"error" < 2 && 3 < 4` will evaluate to **false** and **null**. Why? Well the `"error" < 2` returns **false** and **null**, this failure polluted the the `&&` so that failed too

How about `"error" < 2 || 3 < 4`? Well this will result in **true** and **true** because the error from the left hand side of `||` does not pollute the right hand side

## You can do maths in the query?

To be honest I had to write a full blown expression parser and got carried away. All the maths stuff is probably not needed and could be dropped without affecting the utility of the application. But it is no great overhead

