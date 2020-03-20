import moment from 'moment';
import { parse } from './parse.pegjs';


(typeof window !== 'undefined' ? window : global).i18nTemplateFormat = {
  date (time, format) {
    return moment(time).format(format);
  }
}

export default (str, obj) => parse(str)(obj);