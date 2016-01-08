/*! 2015-05-10 */

!function(a){"use strict";function b(){this.$storage=document.cookie=""}function c(){this.$storage={}}function d(){this.$storage=window.localStorage}function e(){this.$storage=window.sessionStorage}function f(){return d.isAvailable()?h[mx.DEFAULT_STORAGE_NAME]=new d:h[mx.DEFAULT_STORAGE_NAME]=new b}var g=10;b.prototype.set=function(a,b){var c=new Date,d=JSON.stringify(b);c.setTime(c.getTime()+24*g*60*60*1e3);var e="expires="+c.toUTCString();document.cookie=a+"="+d+"; "+e},b.prototype.get=function(a){var b=document.cookie.replace(new RegExp("/(?:(?:^|.*;\\s*)"+a+"\\s*\\=\\s*([^;]*).*$)|^.*$/"),"$1");return b?JSON.parse(b.split("=")[1]):""},b.prototype.remove=function(a){for(var b=a+"=",c=this.$storage.split(";"),d=0;d<c.length;d++){for(var e=c[d];" "==e.charAt(0);)e=e.substring(1);if(0==e.indexOf(b)){var f=this.$storage.indexOf(e);this.$storage=this.$storage.slice(f,f+e.length)}}return""},c.prototype.set=function(a,b){this.$storage[a]=JSON.stringify(b)},c.prototype.get=function(a){return this.$storage[a]?JSON.parse(this.$storage[a]):void 0},c.prototype.remove=function(a){delete this.$storage[a]},d.prototype.set=function(a,b){this.$storage.setItem(a,JSON.stringify(b))},d.prototype.get=function(a){return JSON.parse(this.$storage.getItem(a))},d.prototype.remove=function(a){this.$storage.removeItem(a)},d.isAvailable=function(){return!!window.localStorage},e.prototype.set=function(a,b){this.$storage.setItem(a,JSON.stringify(b))},e.prototype.get=function(a){return JSON.parse(this.$storage.getItem(a))},e.prototype.remove=function(a){this.$storage.removeItem(a)},e.isAvailable=function(){return!!window.sessionStorage},window.mx=window.mx||{};var h={};mx.COOKIE_STORAGE="cookie",mx.LOCAL_STORAGE="local",mx.SESSION_STORAGE="session",mx.IN_MEMORY_STORAGE="in-memory",mx.DEFAULT_STORAGE="default",mx.DEFAULT_STORAGE_NAME="default",mx.storage=function(a,g){var i;if(g){switch(g){case mx.COOKIE_STORAGE:i=new b;break;case mx.LOCAL_STORAGE:i=new d;break;case mx.SESSION_STORAGE:i=new e;break;case mx.IN_MEMORY_STORAGE:i=new c;break;case mx.DEFAULT_STORAGE:i=f();break;default:throw new Error(g+" is not a valid storage type.")}h[a||mx.DEFAULT_STORAGE_NAME]=i}return h[a||mx.DEFAULT_STORAGE_NAME]},f()}(m);
//# sourceMappingURL=mithril-storage.js.map