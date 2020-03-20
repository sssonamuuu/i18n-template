start = content: content {
  return new Function('obj', `var copyObj = Object.assign({}, obj);return ${content.replace(/\n/g, '\\n')};`);
}

content = start: placeholder* next: (str placeholder*)* {
  const res = [];
  res.push(...start);
  next.forEach(([str, placeholder]) => {
    res.push(`'${str}'`);
    res.push(...placeholder);
  });
  return res.join('+');
}

placeholder
  = '{' WS* varName: variable format: format* condition: condition* WS* '}' {
    return '(function(){' +
      format.reduce((p, [fn, params]) => {
        return `${p}copyObj.${varName} = i18nTemplateFormat.${fn}(copyObj.${varName}${params.length ? ', ' : ''}${params.join(', ')});`
      }, '') +
      condition.reduce((p, [operate, value, content]) => {
        if (operate) {
          return `${p}if (copyObj.${varName} ${operate} ${value}) {return ${content};}`
        } else {
          return `${p}return ${content};`;
        }
      }, '') +
      `return copyObj.${varName};` +
    '})()';
  }

format
  = WS* '|' WS* funcName: variable params: param* {
    return [funcName, params];
  }

param
  = WS+ param: valStr {
    return param;
  }

condition
  = WS* operate: operator WS* value: valStr WS* '{' WS* content: content WS* '}' {
    return [operate, value, content];
  }
  / WS* '{' content: content '}' {
    return [null, null, content];
  }

// 普通字符串
str = [^{}]+ { return text(); }

// 作为值的字符串，格式化函数参数、条件判断常量等
valStr
  = '`' param: [^`]+ '`' {
    return `'${param.join('')}'`;
  }
  / param: [^`{=!><} |]+ {
    const res = param.join('');
    if (['true', 'false', 'undefined', 'null'].includes(res) || !isNaN(res)) {
      return res;
    }
    return `'${res}'`;
  }

// 邮箱判断全等、全不等
operator
  =  '===' / '!==' / '>=' / '<=' / '!=' / '==' / '>' / '<'

variable = [a-z0-9_$]i+ { return text(); }

WS = [ ]