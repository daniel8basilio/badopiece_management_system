/**
 * For webpack use!
 * - Require JS libraries here.
 */
window.$ = window.jquery = require('jquery');
require('bootstrap');
require('bootstrap-datepicker');

import * as DateUtils from './date-utils';
window.DateUtils = DateUtils;
