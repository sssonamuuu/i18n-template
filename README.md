# 多语言国际化字符串模板

解决部分不方便在代码中进行逻辑判断展示不同效果的情况，主要针对多语言。

``` javascript
import t from '@front-end-club/i18n-template';

t(templateStr, obj);
```

## obj

`obj` 为一个对象，其中`key`为模板变量中使用到的变量名。

## templateStr

模板字符串格式：

### 1. 模板变量

以花括号包裹，如:

``` javascript
'strstr{aaa}strstr'
```

### 2. 格式化

在模板变量后使用`|`，后面根函数名。**函数名必须存放到全局变量`i18nTemplateFormat`中**，具体后面章节查看。

``` javascript
'strstr{aaa | fn}strstr' // 不带参数
'strstr{aaa | fn param1}strstr' // 带参数情况
'strstr{aaa | fn param1 param2}strstr' // 带多个参数情况
'strstr{aaa | fn1 param1 param2 | fn2 param1}strstr' // 多个格式化管道
```

可以处理如不同国家时间展示不一样问题。如显示：比赛将在{某个时间}开始。一句做多语言，我们使用默认会转换成'YYYY-MM-DD'，但是某些语言中，时间可能需要展示为'MM/DD/YYYY'。

``` javascript
// zh-CN.js
{
  key: 'xxxxxxxx{time | date YYYY-MM-DD}'
}

// en-US.js
{
  key: 'xxxxxxxx{time | date MM/DD/YYYY}',
}
```

这样就避免在代码中进行逻辑处理，在每个语言包中统一管理。

### 3. 条件展示

在模板变量**或则格式化**后通过 `condition{templateStr}`，条件不存在的情况放在最后，表示为`else`。

**格式化后判断是使用格式化函数返回值进行比较的**。

``` javascript
'strstr{aaa ==0{xxx0} ==1{xxx1} {xxxother}}strstr' // 直接使用
'strstr{aaa | fn param1 param2 | fn2 ==0{xxx0} ==1{xxx1} {xxxother}}strstr' // 格式化后判断
```

条件后的内容同样可以再次递归使用模板。

```javascript
'strstr{aaa ==0{xxx0} ==1{xxx1} {xxx{aaa | fn}other}}strstr' // 在条件内容中再次使用模板
```

可以处理单复数问题，如：

``` javascript
// zh-CN.js
{
  key: '我有{n}个苹果'
}

// en-US.js
{
  key: 'I have {n <=1{an apple {{n} apples}}' // 当小于1时候使用单数，否则使用复数
}
```

### 数据类型问题


参数值如'xxxxxxxx{time | date YYYY-MM-DD}' 中的 'YYYY-MM-DD', 条件比较值如：'strstr{aaa ==0{xxx0} ==1{xxx1} {xxxother}}strstr' 中的1。

在出现有空格的情况，使用 "\`" 反引号。如：'xxxxxxxx{time | date \`YYYY-MM-DD HH:mm\`}'。

当在**没有**反引号的时候，如果为 true, false, undefined, null, number，模板数据类型**不会**转化成string，如果需要string，可以添加反引号。

如：'strstr{aaa ==0{xxx0} ==1{xxx1} {xxxother}}strstr' 中的1 默认为number，如果需要类型为string，可以使用'strstr{aaa ==0{xxx0} ==\`1\`{xxx1} {xxxother}}strstr'

### 添加比较关系可以使用：

'===' / '!==' / '>=' / '<=' / '!=' / '==' / '>' / '<'

### 格式化函数

格式化函数放在全局变量`i18nTemplateFormat`中，使用函数名作为`key`，函数参数第一个默认为当前模板变量值，之后依次为模板格式化传入参数。

如：

``` javascript
import t from '@front-end-club/i18n-template';

// 模板为：
'strstr{aaa | test 1 2 3}strstr' // 直接使用

i18nTemplateFormat.test = function (aaa, param1, param2, param3) {
  console.log(aaa, param1, param2, param3); // aaa 1 2 3
}

t(t, { aaa: 'aaa' })
```


### 内置函数

1. date(format)

`format` 为 `moment` `fromat` 参数。