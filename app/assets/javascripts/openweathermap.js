/*!
 * OpenWeatherMap
 * Copyright © 2012-2016 OpenWeatherMap, Inc.
 * Simplifed and compressed version of weather-widget-generator.js
 */

(function e(t, n, r) {
  function s(o, u) {
    if (!n[o]) {
      if (!t[o]) {
        var a = typeof require == "function" && require;
        if (!u && a) return a(o, !0);
        if (i) return i(o, !0);
        var f = new Error("Cannot find module '" + o + "'");
        throw f.code = "MODULE_NOT_FOUND", f
      }
      var l = n[o] = {
        exports: {}
      };
      t[o][0].call(l.exports, function (e) {
        var n = t[o][1][e];
        return s(n ? n : e)
      }, l, l.exports, e, t, n, r)
    }
    return n[o].exports
  }
  var i = typeof require == "function" && require;
  for (var o = 0; o < r.length; o++) s(r[o]);
  return s
})({
  1: [function (require, module, exports) {
    'use strict';

    Object.defineProperty(exports, "__esModule", {
      value: true
    });

    var _createClass = function () {
      function defineProperties(target, props) {
        for (var i = 0; i < props.length; i++) {
          var descriptor = props[i];
          descriptor.enumerable = descriptor.enumerable || false;
          descriptor.configurable = true;
          if ("value" in descriptor) descriptor.writable = true;
          Object.defineProperty(target, descriptor.key, descriptor);
        }
      }
      return function (Constructor, protoProps, staticProps) {
        if (protoProps) defineProperties(Constructor.prototype, protoProps);
        if (staticProps) defineProperties(Constructor, staticProps);
        return Constructor;
      };
    }();

    function _classCallCheck(instance, Constructor) {
      if (!(instance instanceof Constructor)) {
        throw new TypeError("Cannot call a class as a function");
      }
    }

    function _possibleConstructorReturn(self, call) {
      if (!self) {
        throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
      }
      return call && (typeof call === "object" || typeof call === "function") ? call : self;
    }

    function _inherits(subClass, superClass) {
      if (typeof superClass !== "function" && superClass !== null) {
        throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
      }
      subClass.prototype = Object.create(superClass && superClass.prototype, {
        constructor: {
          value: subClass,
          enumerable: false,
          writable: true,
          configurable: true
        }
      });
      if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
    }

    /**
     * Created by Denis on 28.09.2016.
     */

    // Работа с датой
    var CustomDate = function (_Date) {
      _inherits(CustomDate, _Date);

      function CustomDate() {
        _classCallCheck(this, CustomDate);

        return _possibleConstructorReturn(this, (CustomDate.__proto__ || Object.getPrototypeOf(CustomDate)).apply(this, arguments));
      }

      _createClass(CustomDate, [{
        key: 'numberDaysOfYearXXX',


        /**
         * метод преобразования номера дня в году в трехразрядное число ввиде строки
         * @param  {[integer]} number [число менее 999]
         * @return {[string]}        [трехзначное число ввиде строки порядкового номера дня в году]
         */
        value: function numberDaysOfYearXXX(number) {
          if (number > 365) {
            return false;
          }
          if (number < 10) {
            return '00' + number;
          } else if (number < 100) {
            return '0' + number;
          }
          return number;
        }

        /**
         * Метод определения порядкового номера в году
         * @param  {date} date Дата формата yyyy-mm-dd
         * @return {integer}  Порядковый номер в году
         */

      }, {
        key: 'convertDateToNumberDay',
        value: function convertDateToNumberDay(date) {
          var now = new Date(date);
          var start = new Date(now.getFullYear(), 0, 0);
          var diff = now - start;
          var oneDay = 1000 * 60 * 60 * 24;
          var day = Math.floor(diff / oneDay);
          return now.getFullYear() + '-' + this.numberDaysOfYearXXX(day);
        }

        /**
         * Метод преообразует дату формата yyyy-<number day in year> в yyyy-mm-dd
         * @param  {string} date дата формата yyyy-<number day in year>
         * @return {date} дата формата yyyy-mm-dd
         */

      }, {
        key: 'convertNumberDayToDate',
        value: function convertNumberDayToDate(date) {
          var re = /(\d{4})(-)(\d{3})/;
          var line = re.exec(date);
          var beginyear = new Date(line[1]);
          var unixtime = beginyear.getTime() + line[3] * 1000 * 60 * 60 * 24;
          var res = new Date(unixtime);

          var month = res.getMonth() + 1;
          var days = res.getDate();
          var year = res.getFullYear();
          return (days < 10 ? '0' + days : days) + '.' + (month < 10 ? '0' + month : month) + '.' + year;
        }

        /**
         * Метод преобразования даты вида yyyy-<number day in year>
         * @param  {date1} date дата в формате yyyy-mm-dd
         * @return {string}  дата ввиде строки формата yyyy-<number day in year>
         */

      }, {
        key: 'formatDate',
        value: function formatDate(date1) {
          var date = new Date(date1);
          var year = date.getFullYear();
          var month = date.getMonth() + 1;
          var day = date.getDate();

          return year + '-' + (month < 10 ? '0' + month : month) + ' - ' + (day < 10 ? '0' + day : day);
        }

        /**
         * Метод возвращает текущую отформатированную дату yyyy-mm-dd
         * @return {[string]} текущая дата
         */

      }, {
        key: 'getCurrentDate',
        value: function getCurrentDate() {
          var now = new Date();
          return this.formatDate(now);
        }

        // Возвращает последние три месяца

      }, {
        key: 'getDateLastThreeMonth',
        value: function getDateLastThreeMonth() {
          var now = new Date();
          var year = new Date().getFullYear();
          var start = new Date(now.getFullYear(), 0, 0);
          var diff = now - start;
          var oneDay = 1000 * 60 * 60 * 24;
          var day = Math.floor(diff / oneDay);
          day -= 90;
          if (day < 0) {
            year -= 1;
            day = 365 - day;
          }
          return year + '-' + this.numberDaysOfYearXXX(day);
        }

        // Возвращает интервал дат текущего лета

      }, {
        key: 'getCurrentSummerDate',
        value: function getCurrentSummerDate() {
          var year = new Date().getFullYear();
          var dateFr = this.convertDateToNumberDay(year + '-06-01');
          var dateTo = this.convertDateToNumberDay(year + '-08-31');
          return [dateFr, dateTo];
        }

        // Возвращает интервал дат текущего лета

      }, {
        key: 'getCurrentSpringDate',
        value: function getCurrentSpringDate() {
          var year = new Date().getFullYear();
          var dateFr = this.convertDateToNumberDay(year + '-03-01');
          var dateTo = this.convertDateToNumberDay(year + '-05-31');
          return [dateFr, dateTo];
        }

        // Возвращает интервал дат предыдущего лета

      }, {
        key: 'getLastSummerDate',
        value: function getLastSummerDate() {
          var year = new Date().getFullYear() - 1;
          var dateFr = this.convertDateToNumberDay(year + '-06-01');
          var dateTo = this.convertDateToNumberDay(year + '-08-31');
          return [dateFr, dateTo];
        }
      }, {
        key: 'getFirstDateCurYear',
        value: function getFirstDateCurYear() {
          return new Date().getFullYear() + ' - 001';
        }

        /**
         * [timestampToDate unixtime to dd.mm.yyyy hh:mm]
         * @param  {[type]} timestamp [description]
         * @return {string}           [description]
         */

      }, {
        key: 'timestampToDateTime',
        value: function timestampToDateTime(unixtime) {
          var date = new Date(unixtime * 1000);
          return date.toLocaleString().replace(/,/, '').replace(/:\w+$/, '');
        }

        /**
         * [timestampToDate unixtime to hh:mm]
         * @param  {[type]} timestamp [description]
         * @return {string}           [description]
         */

      }, {
        key: 'timestampToTime',
        value: function timestampToTime(unixtime) {
          var date = new Date(unixtime * 1000);
          var hours = date.getHours();
          var minutes = date.getMinutes();
          return (hours < 10 ? '0' + hours : hours) + ' : ' + (minutes < 10 ? '0' + minutes : minutes) + ' ';
        }

        /**
         * Возращение номера дня в неделе по unixtime timestamp
         * @param unixtime
         * @returns {number}
         */

      }, {
        key: 'getNumberDayInWeekByUnixTime',
        value: function getNumberDayInWeekByUnixTime(unixtime) {
          var date = new Date(unixtime * 1000);
          return date.getDay();
        }

        /** Вернуть наименование дня недели
         * @param dayNumber
         * @returns {string}
         */

      }, {
        key: 'getDayNameOfWeekByDayNumber',
        value: function getDayNameOfWeekByDayNumber(dayNumber, lang) {
          var lang = myWidgetParam.lang ? myWidgetParam.lang : "en";
          var days = { 
            "en": {
              0: 'Sun',
              1: 'Mon',
              2: 'Tue',
              3: 'Wed',
              4: 'Thu',
              5: 'Fri',
              6: 'Sat'
            }, "fr": {
              0: 'Dim',
              1: 'Lun',
              2: 'Mar',
              3: 'Mer',
              4: 'Jeu',
              5: 'Ven',
              6: 'Sam'
            } 
          };
          return days[lang][dayNumber];
        }

        /**
         * Вернуть Наименование месяца по его номеру
         * @param numMonth
         * @returns {*}
         */

      }, {
        key: 'getMonthNameByMonthNumber',
        value: function getMonthNameByMonthNumber(numMonth) {

          if (typeof numMonth !== "number" || numMonth <= 0 && numMonth >= 12) {
            return null;
          }

          var monthName = {
            0: "Jan",
            1: "Feb",
            2: "Mar",
            3: "Apr",
            4: "May",
            5: "Jun",
            6: "Jul",
            7: "Aug",
            8: "Sep",
            9: "Oct",
            10: "Nov",
            11: "Dec"
          };

          return monthName[numMonth];
        }

        /** Сравнение даты в формате dd.mm.yyyy = dd.mm.yyyy с текущим днем
         *
         */

      }, {
        key: 'compareDatesWithToday',
        value: function compareDatesWithToday(date) {
          return date.toLocaleDateString() === new Date().toLocaleDateString();
        }
      }, {
        key: 'convertStringDateMMDDYYYHHToDate',
        value: function convertStringDateMMDDYYYHHToDate(date) {
          var re = /(\d{2})(\.{1})(\d{2})(\.{1})(\d{4})/;
          var resDate = re.exec(date);
          if (resDate.length === 6) {
            return new Date(resDate[5] + '-' + resDate[3] + '-' + resDate[1]);
          }
          // Если дата не распарсена берем текущую
          return new Date();
        }

        /**
         * Возвращает дату в формате HH:MM MonthName NumberDate
         * @returns {string}
         */

      }, {
        key: 'getTimeDateHHMMMonthDay',
        value: function getTimeDateHHMMMonthDay() {
          var date = new Date();
          return (date.getHours() < 10 ? '0' + date.getHours() : date.getHours()) + ':' + (date.getMinutes() < 10 ? '0' + date.getMinutes() : date.getMinutes()) + ' ' + this.getMonthNameByMonthNumber(date.getMonth()) + ' ' + date.getDate();
        }
      }]);

      return CustomDate;
    }(Date);

    exports.default = CustomDate;

  }, {}],
  2: [function (require, module, exports) {
    "use strict";

    Object.defineProperty(exports, "__esModule", {
      value: true
    });
    /**
     * Created by Denis on 20.10.2016.
     */
    var naturalPhenomenon = exports.naturalPhenomenon = {
      "en": {
        "name": "English",
        "main": "",
        "description": {
          "200": "thunderstorm with light rain",
          "201": "thunderstorm with rain",
          "202": "thunderstorm with heavy rain",
          "210": "light thunderstorm",
          "211": "thunderstorm",
          "212": "heavy thunderstorm",
          "221": "ragged thunderstorm",
          "230": "thunderstorm with light drizzle",
          "231": "thunderstorm with drizzle",
          "232": "thunderstorm with heavy drizzle",
          "300": "light intensity drizzle",
          "301": "drizzle",
          "302": "heavy intensity drizzle",
          "310": "light intensity drizzle rain",
          "311": "drizzle rain",
          "312": "heavy intensity drizzle rain",
          "313": "shower rain and drizzle",
          "314": "heavy shower rain and drizzle",
          "321": "shower drizzle",
          "500": "light rain",
          "501": "moderate rain",
          "502": "heavy intensity rain",
          "503": "very heavy rain",
          "504": "extreme rain",
          "511": "freezing rain",
          "520": "light intensity shower rain",
          "521": "shower rain",
          "522": "heavy intensity shower rain",
          "531": "ragged shower rain",
          "600": "light snow",
          "601": "snow",
          "602": "heavy snow",
          "611": "sleet",
          "612": "shower sleet",
          "615": "light rain and snow",
          "616": "rain and snow",
          "620": "light shower snow",
          "621": "shower snow",
          "622": "heavy shower snow",
          "701": "mist",
          "711": "smoke",
          "721": "haze",
          "731": "sand,dust whirls",
          "741": "fog",
          "751": "sand",
          "761": "dust",
          "762": "volcanic ash",
          "771": "squalls",
          "781": "tornado",
          "800": "clear sky",
          "801": "few clouds",
          "802": "scattered clouds",
          "803": "broken clouds",
          "804": "overcast clouds",
          "900": "tornado",
          "901": "tropical storm",
          "902": "hurricane",
          "903": "cold",
          "904": "hot",
          "905": "windy",
          "906": "hail",
          "950": "setting",
          "951": "calm",
          "952": "light breeze",
          "953": "gentle breeze",
          "954": "moderate breeze",
          "955": "fresh breeze",
          "956": "strong breeze",
          "957": "high wind, near gale",
          "958": "gale",
          "959": "severe gale",
          "960": "storm",
          "961": "violent storm",
          "962": "hurricane"
        }
      },
      "fr": {
        "name": "French",
        "main": "",
        "description": {
          "200": "orage et pluie fine",
          "201": "orage et pluie",
          "202": "orage et fortes pluies",
          "210": "orages légers",
          "211": "orages",
          "212": "gros orages",
          "221": "orages éparses",
          "230": "Orage avec légère bruine",
          "231": "orages éparses",
          "232": "gros orage",
          "300": "Bruine légère",
          "301": "Bruine",
          "302": "Fortes bruines",
          "310": "Pluie fine éparse",
          "311": "pluie fine",
          "312": "Crachin intense",
          "321": "Averses de bruine",
          "500": "légères pluies",
          "501": "pluies modérées",
          "502": "Fortes pluies",
          "503": "très fortes précipitations",
          "504": "grosses pluies",
          "511": "pluie verglaçante",
          "520": "petites averses",
          "521": "averses de pluie",
          "522": "averses intenses",
          "600": "légères neiges",
          "601": "neige",
          "602": "fortes chutes de neige",
          "611": "neige fondue",
          "621": "averses de neige",
          "701": "brume",
          "711": "Brouillard",
          "721": "brume",
          "731": "tempêtes de sable",
          "741": "brouillard",
          "800": "ensoleillé",
          "801": "peu nuageux",
          "802": "partiellement ensoleillé",
          "803": "nuageux",
          "804": "Couvert",
          "900": "tornade",
          "901": "tempête tropicale",
          "902": "ouragan",
          "903": "froid",
          "904": "chaud",
          "905": "venteux",
          "906": "grêle",
          "950": "Très calme",
          "951": "Calme",
          "952": "Brise légère",
          "953": "Brise douce",
          "954": "Brise modérée",
          "955": "Brise fraiche",
          "956": "Brise forte",
          "957": "Vent fort, presque violent",
          "958": "Vent violent",
          "959": "Vent très violent",
          "960": "Tempête",
          "961": "Tempête violente",
          "962": "Ouragan"
        }
      }
    };

  }, {}],
  3: [function (require, module, exports) {
    "use strict";

    Object.defineProperty(exports, "__esModule", {
      value: true
    });
    /**
     * Created by Denis on 20.10.2016.
     */
    var windSpeed = exports.windSpeed = {
      "en": {
        "Settings": { "speed_interval": [0.0, 0.3] },
        "Calm": { "speed_interval": [0.3, 1.6] },
        "Light breeze": { "speed_interval": [1.6, 3.3] },
        "Gentle Breeze": { "speed_interval": [3.4, 5.5] },
        "Moderate breeze": { "speed_interval": [5.5, 8.0] },
        "Fresh Breeze": { "speed_interval": [8.0, 10.8] },
        "Strong breeze": { "speed_interval": [10.8, 13.9] },
        "High wind, near gale": { "speed_interval": [13.9, 17.2] },
        "Gale": { "speed_interval": [17.2, 20.7] },
        "Severe Gale": { "speed_interval": [20.8, 24.5] },
        "Storm": { "speed_interval": [24.5, 28.5] },
        "Violent Storm": { "speed_interval": [28.5, 32.7] },
        "Hurricane": { "speed_interval": [32.7, 64] }
      },
      "fr" : {
        "Très calme": { "speed_interval": [0.0, 0.3] },
        "Calme": { "speed_interval": [0.3, 1.6] },
        "Brise légère": { "speed_interval": [1.6, 3.3] },
        "Brise douce": { "speed_interval": [3.4, 5.5] },
        "Brise modérée": { "speed_interval": [5.5, 8.0] },
        "Brise fraiche": { "speed_interval": [8.0, 10.8] },
        "Brise forte": { "speed_interval": [10.8, 13.9] },
        "Vent fort, presque violent": { "speed_interval": [13.9, 17.2] },
        "Vent violent": { "speed_interval": [17.2, 20.7] },
        "Vent très violent": { "speed_interval": [20.8, 24.5] },
        "Tempête": { "speed_interval": [24.5, 28.5] },
        "Tempête violente": { "speed_interval": [28.5, 32.7] },
        "Ouragan": { "speed_interval": [32.7, 64] }
      }
    };

  }, {}],
  4: [function (require, module, exports) {
    'use strict';

    Object.defineProperty(exports, "__esModule", {
      value: true
    });

    var _createClass = function () {
      function defineProperties(target, props) {
        for (var i = 0; i < props.length; i++) {
          var descriptor = props[i];
          descriptor.enumerable = descriptor.enumerable || false;
          descriptor.configurable = true;
          if ("value" in descriptor) descriptor.writable = true;
          Object.defineProperty(target, descriptor.key, descriptor);
        }
      }
      return function (Constructor, protoProps, staticProps) {
        if (protoProps) defineProperties(Constructor.prototype, protoProps);
        if (staticProps) defineProperties(Constructor, staticProps);
        return Constructor;
      };
    }();

    function _classCallCheck(instance, Constructor) {
      if (!(instance instanceof Constructor)) {
        throw new TypeError("Cannot call a class as a function");
      }
    }

    /**
     * Created by Denis on 13.10.2016.
     */
    var GeneratorWidget = function () {
      function GeneratorWidget() {
        _classCallCheck(this, GeneratorWidget);

        this.baseURL = 'http://openweathermap.org/themes/openweathermap/assets/vendor/owm';

        this.domElements = {
          id21: {
            id: 21,
            type: 'left',
            schema: 'white',
            dom: '<div class="widget-left"> <div class="widget-left-menu"> <div class="widget-left-menu__layout"> <h1 class="widget-left-menu__header"></h1> <div class="widget-left-menu__links"><a href="//openweathermap.org/" target="_blank" class="widget-left-menu__link">OpenWeatherMap</a></div> </div></div>' 
            + '<div class="widget-left__body"> <div class="weather-left-card weather-left-card--grayscale"> <div class="weather-left-card__row1"> <img src="" width="128" height="128" alt="" class="weather-left-card__img"/> <div class="weather-left-card__col"> <p class="weather-left-card__number">0<span class="weather-left-card__degree">&176;</span></p> </div></div><div class="weather-left-card__row2"> <p class="weather-left-card__means">-</p><p class="weather-left-card__wind">Wind:</p></div></div>' 
            + '<div class="widget-left__calendar"> <ul class="calendar calendar--grayscale"> <li class="calendar__item"><img src="" width="32" height="32" alt=""/></li><li class="calendar__item"><img src="" width="32" height="32" alt=""/></li><li class="calendar__item"><img src="" width="32" height="32" alt=""/></li><li class="calendar__item"><img src="" width="32" height="32" alt=""/></li><li class="calendar__item"><img src="" width="32" height="32" alt=""/></li><li class="calendar__item"><img src="" width="32" height="32" alt=""/></li><li class="calendar__item"><img src="" width="32" height="32" alt=""/></li><li class="calendar__item"><img src="" width="32" height="32" alt=""/></li></ul> <div id="graphic" class="widget-left__graphic"></div></div></div></div>'
          }
        };
      }

      _createClass(GeneratorWidget, [{
        key: 'render',
        value: function render() {
          if (window.myWidgetParam) {
            this.selDOMElement = this.domElements['id' + window.myWidgetParam.id];
            var container = document.getElementById(window.myWidgetParam.containerid);
            container.insertAdjacentHTML('afterbegin', this.selDOMElement.dom);
          }
        }
      }]);

      return GeneratorWidget;
    }();

    exports.default = GeneratorWidget;

  }, {}],
  5: [function (require, module, exports) {
    'use strict';

    Object.defineProperty(exports, "__esModule", {
      value: true
    });

    var _createClass = function () {
      function defineProperties(target, props) {
        for (var i = 0; i < props.length; i++) {
          var descriptor = props[i];
          descriptor.enumerable = descriptor.enumerable || false;
          descriptor.configurable = true;
          if ("value" in descriptor) descriptor.writable = true;
          Object.defineProperty(target, descriptor.key, descriptor);
        }
      }
      return function (Constructor, protoProps, staticProps) {
        if (protoProps) defineProperties(Constructor.prototype, protoProps);
        if (staticProps) defineProperties(Constructor, staticProps);
        return Constructor;
      };
    }();

    var _customDate = require('./custom-date');

    var _customDate2 = _interopRequireDefault(_customDate);

    function _interopRequireDefault(obj) {
      return obj && obj.__esModule ? obj : {
        default: obj
      };
    }

    function _classCallCheck(instance, Constructor) {
      if (!(instance instanceof Constructor)) {
        throw new TypeError("Cannot call a class as a function");
      }
    }

    function _possibleConstructorReturn(self, call) {
      if (!self) {
        throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
      }
      return call && (typeof call === "object" || typeof call === "function") ? call : self;
    }

    function _inherits(subClass, superClass) {
      if (typeof superClass !== "function" && superClass !== null) {
        throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
      }
      subClass.prototype = Object.create(superClass && superClass.prototype, {
        constructor: {
          value: subClass,
          enumerable: false,
          writable: true,
          configurable: true
        }
      });
      if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
    }
    /**
     * Created by Denis on 29.09.2016.
     */

    /**
     График температуры и погоды
     @class Graphic
     */
    var Graphic = function (_CustomDate) {
      _inherits(Graphic, _CustomDate);

      function Graphic(params) {
        _classCallCheck(this, Graphic);

        var _this = _possibleConstructorReturn(this, (Graphic.__proto__ || Object.getPrototypeOf(Graphic)).call(this));

        _this.params = params;
        /**
         * метод для расчета отрисовки основной линии параметра температуры
         * [line description]
         * @return {[type]} [description]
         */
        _this.temperaturePolygon = d3.line().x(function (d) {
          return d.x;
        }).y(function (d) {
          return d.y;
        });
        return _this;
      }

      /**
       * Преобразуем объект данных в массив для формирования графика
       * @param  {[boolean]} temperature [признак для построения графика]
       * @return {[array]}   rawData [массив с адаптированными по типу графика данными]
       */


      _createClass(Graphic, [{
        key: 'prepareData',
        value: function prepareData() {
          var i = 0;
          var rawData = [];

          this.params.data.forEach(function (elem) {
            rawData.push({
              x: i,
              date: i,
              maxT: elem.max,
              minT: elem.min
            });
            i += 1; // Смещение по оси X
          });

          return rawData;
        }

        /**
         * Создаем изображение с контекстом объекта svg
         * [makeSVG description]
         * @return {[object]}
         */

      }, {
        key: 'makeSVG',
        value: function makeSVG() {
          return d3.select(this.params.id).append('svg').attr('class', 'axis').attr('width', this.params.width).attr('height', this.params.height).attr('fill', this.params.colorPolilyne).style('stroke', '#ffffff');
        }

        /**
         * Определение минималльного и максимального элемента по параметру даты
         * [getMinMaxDate description]
         * @param  {[array]} rawData [массив с адаптированными по типу графика данными]
         * @return {[object]} data [объект с минимальным и максимальным значением]
         */

      }, {
        key: 'getMinMaxDate',
        value: function getMinMaxDate(rawData) {
          /* Определяем минимальные и максмальные значения для построения осей */
          var data = {
            maxDate: 0,
            minDate: 10000
          };

          rawData.forEach(function (elem) {
            if (data.maxDate <= elem.date) {
              data.maxDate = elem.date;
            }
            if (data.minDate >= elem.date) {
              data.minDate = elem.date;
            }
          });

          return data;
        }

        /**
         * Определяем минимальные и максимальные значения дат и температуры
         * [getMinMaxDateTemperature description]
         * @param  {[object]} rawData [description]
         * @return {[object]}         [description]
         */

      }, {
        key: 'getMinMaxTemperature',
        value: function getMinMaxTemperature(rawData) {
          /* Определяем минимальные и максмальные значения для построения осей */
          var data = {
            min: 100,
            max: 0
          };

          rawData.forEach(function (elem) {
            if (data.min >= elem.minT) {
              data.min = elem.minT;
            }
            if (data.max <= elem.maxT) {
              data.max = elem.maxT;
            }
          });

          return data;
        }

        /**
         *
         * [getMinMaxWeather description]
         * @param  {[type]} rawData [description]
         * @return {[type]}         [description]
         */

      }, {
        key: 'getMinMaxWeather',
        value: function getMinMaxWeather(rawData) {
          /* Определяем минимальные и максмальные значения для построения осей */
          var data = {
            min: 0,
            max: 0
          };

          rawData.forEach(function (elem) {
            if (data.min >= elem.humidity) {
              data.min = elem.humidity;
            }
            if (data.min >= elem.rainfallAmount) {
              data.min = elem.rainfallAmount;
            }
            if (data.max <= elem.humidity) {
              data.max = elem.humidity;
            }
            if (data.max <= elem.rainfallAmount) {
              data.max = elem.rainfallAmount;
            }
          });

          return data;
        }

        /**
         * Определяем длину осей X,Y
         * [makeAxesXY description]
         * @param  {[array]} rawData [Массив с данными для построения графика]
         * @param  {[integer]} margin  [отступы от краев графика]
         * @return {[function]}         [description]
         */

      }, {
        key: 'makeAxesXY',
        value: function makeAxesXY(rawData, params) {
          // длина оси X= ширина контейнера svg - отступ слева и справа
          var xAxisLength = params.width - 2 * params.margin;
          // длина оси Y = высота контейнера svg - отступ сверху и снизу
          var yAxisLength = params.height - 2 * params.margin;

          return this.scaleAxesXYTemperature(rawData, xAxisLength, yAxisLength, params);
        }

        /**
         * // функция интерполяции значений на оси Х и Y
         * [scaleAxesXY description]
         * @param  {[object]}  rawData     [Объект с данными для построения графика]
         * @param  {function} xAxisLength [интерполирование значений на ось X]
         * @param  {function} yAxisLength [интерполирование значений на ось Y]
         * @param  {[type]}  margin      [отступы от краев графика]
         * @return {[array]}              [массив с интерполированными значениями]
         */

      }, {
        key: 'scaleAxesXYTemperature',
        value: function scaleAxesXYTemperature(rawData, xAxisLength, yAxisLength, params) {
          var _getMinMaxDate = this.getMinMaxDate(rawData);

          var maxDate = _getMinMaxDate.maxDate;
          var minDate = _getMinMaxDate.minDate;

          var _getMinMaxTemperature = this.getMinMaxTemperature(rawData);

          var min = _getMinMaxTemperature.min;
          var max = _getMinMaxTemperature.max;

          /**
           * метод интерполяции значений на ось Х
           * [scaleTime description]
           */

          var scaleX = d3.scaleTime().domain([new Date(minDate), new Date(maxDate)]).range([0, xAxisLength]);

          /**
           * метод интерполяции значений на ось Y
           * [scaleLinear description]
           * @return {[type]} [description]
           */
          var scaleY = d3.scaleLinear().domain([max + 5, min - 5]).range([0, yAxisLength]);

          var data = [];
          // масштабирование реальных данных в данные для нашей координатной системы
          rawData.forEach(function (elem) {
            data.push({
              x: scaleX(elem.date) + params.offsetX,
              maxT: scaleY(elem.maxT) + params.offsetX,
              minT: scaleY(elem.minT) + params.offsetX
            });
          });

          return {
            scaleX: scaleX,
            scaleY: scaleY,
            data: data
          };
        }
      }, {
        key: 'scaleAxesXYWeather',
        value: function scaleAxesXYWeather(rawData, xAxisLength, yAxisLength, margin) {
          var _getMinMaxDate2 = this.getMinMaxDate(rawData);

          var maxDate = _getMinMaxDate2.maxDate;
          var minDate = _getMinMaxDate2.minDate;

          var _getMinMaxWeather = this.getMinMaxWeather(rawData);

          var min = _getMinMaxWeather.min;
          var max = _getMinMaxWeather.max;

          // функция интерполяции значений на ось Х

          var scaleX = d3.scaleTime().domain([new Date(minDate), new Date(maxDate)]).range([0, xAxisLength]);

          // функция интерполяции значений на ось Y
          var scaleY = d3.scaleLinear().domain([max, min]).range([0, yAxisLength]);
          var data = [];

          // масштабирование реальных данных в данные для нашей координатной системы
          rawData.forEach(function (elem) {
            data.push({
              x: scaleX(elem.date) + margin,
              humidity: scaleY(elem.humidity) + margin,
              rainfallAmount: scaleY(elem.rainfallAmount) + margin,
              color: elem.color
            });
          });

          return {
            scaleX: scaleX,
            scaleY: scaleY,
            data: data
          };
        }

        /**
         * Формивароние массива для рисования полилинии
         * [makePolyline description]
         * @param  {[array]} data [массив с интерполированными значениями]
         * @param  {[integer]} margin [отступ от краев графика]
         * @param  {[object]} scaleX, scaleY [объекты с функциями интерполяции X,Y]
         * @return {[type]}  [description]
         */

      }, {
        key: 'makePolyline',
        value: function makePolyline(data, params, scaleX, scaleY) {
            var arrPolyline = [];
            data.forEach(function (elem) {
              arrPolyline.push({
                x: scaleX(elem.date) + params.offsetX,
                y: scaleY(elem.maxT) + params.offsetY
              });
            });
            data.reverse().forEach(function (elem) {
              arrPolyline.push({
                x: scaleX(elem.date) + params.offsetX,
                y: scaleY(elem.minT) + params.offsetY
              });
            });
            arrPolyline.push({
              x: scaleX(data[data.length - 1].date) + params.offsetX,
              y: scaleY(data[data.length - 1].maxT) + params.offsetY
            });

            return arrPolyline;
          }
          /**
           * Отрисовка полилиний с заливкой основной и имитация ее тени
           * [drawPoluline description]
           * @param  {[type]} svg  [description]
           * @param  {[type]} data [description]
           * @return {[type]}      [description]
           */

      }, {
        key: 'drawPolyline',
        value: function drawPolyline(svg, data) {
            // добавляем путь и рисуем линии

            svg.append('g').append('path').style('stroke-width', this.params.strokeWidth).attr('d', this.temperaturePolygon(data)).style('stroke', this.params.colorPolilyne).style('fill', this.params.colorPolilyne).style('opacity', 1);
          }
          /**
           * Отрисовка надписей с показателями температуры на осях
           * @param  {[type]} svg    [description]
           * @param  {[type]} data   [description]
           * @param  {[type]} params [description]
           * @return {[type]}        [description]
           */

      }, {
        key: 'drawLabelsTemperature',
        value: function drawLabelsTemperature(svg, data, params) {
          data.forEach(function (elem, item, data) {
            // отрисовка текста
            svg.append('text').attr('x', elem.x).attr('y', elem.maxT - 2 - params.offsetX / 2).attr('text-anchor', 'middle').style('font-size', params.fontSize).style('stroke', params.fontColor).style('fill', params.fontColor).text(params.data[item].max + '°');

            svg.append('text').attr('x', elem.x).attr('y', elem.minT + 7 + params.offsetY / 2).attr('text-anchor', 'middle').style('font-size', params.fontSize).style('stroke', params.fontColor).style('fill', params.fontColor).text(params.data[item].min + '°');
          });
        }

        /**
         * Метод диспетчер прорисовка графика со всеми элементами
         * [render description]
         * @return {[type]} [description]
         */

      }, {
        key: 'render',
        value: function render() {
          var svg = this.makeSVG();
          var rawData = this.prepareData();

          var _makeAxesXY = this.makeAxesXY(rawData, this.params);

          var scaleX = _makeAxesXY.scaleX;
          var scaleY = _makeAxesXY.scaleY;
          var data = _makeAxesXY.data;

          var polyline = this.makePolyline(rawData, this.params, scaleX, scaleY);
          this.drawPolyline(svg, polyline);
          this.drawLabelsTemperature(svg, data, this.params);
          // this.drawMarkers(svg, polyline, this.margin);
        }
      }]);

      return Graphic;
    }(_customDate2.default);

    exports.default = Graphic;

  }, {
    "./custom-date": 1
  }],
  6: [function (require, module, exports) {
    'use strict';

    var _weatherWidget = require('./weather-widget');

    var _weatherWidget2 = _interopRequireDefault(_weatherWidget);

    var _generatorWidget = require('./generator-widget');

    var _generatorWidget2 = _interopRequireDefault(_generatorWidget);

    function _interopRequireDefault(obj) {
      return obj && obj.__esModule ? obj : {
        default: obj
      };
    }

    //Рисуем DOM дерево

    // Модуль диспетчер для отрисовки баннерров на конструкторе
    var generateWidget = new _generatorWidget2.default();
    generateWidget.render();
    if (window.myWidgetParam) {
      var q = '';
      // Формируем параметр фильтра по городу
      if (window.myWidgetParam.cityid) {
        q = '?id=' + window.myWidgetParam.cityid;
      } else if (window.myWidgetParam.city_name) {
        q = '?q=' + window.myWidgetParam.city_name;
      } else {
        q = '?q=London';
      }

      // Установка цвета кривых для графика
      var colorPolilyne = "#000";
      if (generateWidget.selDOMElement.colorPolilyne) {
        colorPolilyne = generateWidget.selDOMElement.colorPolilyne;
      }

      var paramsWidget = {
        cityName: 'Montreal',
        lang: window.myWidgetParam.lang ? window.myWidgetParam.lang : 'en',
        appid: window.myWidgetParam.appid,
        units: 'metric',
        textUnitTemp: String.fromCodePoint(0x00B0), // 248
        colorPolilyne: colorPolilyne,
        baseURL: generateWidget.baseURL,
        urlDomain: 'http://api.openweathermap.org'
      };

      var controlsWidget = {
        // Первая половина виджетов
        cityName: document.querySelectorAll('.widget-left-menu__header'),
        temperature: document.querySelectorAll('.weather-left-card__number'),
        naturalPhenomenon: document.querySelectorAll('.weather-left-card__means'),
        windSpeed: document.querySelectorAll('.weather-left-card__wind'),
        mainIconWeather: document.querySelectorAll('.weather-left-card__img'),
        calendarItem: document.querySelectorAll('.calendar__item'),
        graphic: document.getElementById('graphic'),
        // Вторая половина виджетов
        cityName2: document.querySelectorAll('.widget-right__title'),
        temperature2: document.querySelectorAll('.weather-right__temperature'),
        temperatureFeels: document.querySelectorAll('.weather-right__feels'),
        temperatureMin: document.querySelectorAll('.weather-right-card__temperature-min'),
        temperatureMax: document.querySelectorAll('.weather-right-card__temperature-max'),
        naturalPhenomenon2: document.querySelectorAll('.widget-right__description'),
        windSpeed2: document.querySelectorAll('.weather-right__wind-speed'),
        mainIconWeather2: document.querySelectorAll('.weather-right__icon'),
        humidity: document.querySelectorAll('.weather-right__humidity'),
        pressure: document.querySelectorAll('.weather-right__pressure'),
        dateReport: document.querySelectorAll(".widget-right__date")
      };

      var urls = {
        urlWeatherAPI: paramsWidget.urlDomain + '/data/2.5/weather' + q + '&units=' + paramsWidget.units + '&appid=' + paramsWidget.appid + '&lang=' + paramsWidget.lang,
        paramsUrlForeDaily: paramsWidget.urlDomain + '/data/2.5/forecast/daily' + q + '&units=' + paramsWidget.units + '&cnt=8&appid=' + paramsWidget.appid,
        windSpeed: paramsWidget.baseURL + '/data/wind-speed-data.json',
        windDirection: paramsWidget.baseURL + '/data/wind-direction-data.json',
        clouds: paramsWidget.baseURL + 'data/clouds-data.json',
        naturalPhenomenon: paramsWidget.baseURL + '/data/natural-phenomenon-data.json'
      };

      var objWidget = new _weatherWidget2.default(paramsWidget, controlsWidget, urls);
      if (controlsWidget.cityName.length || controlsWidget.cityName2.length) {
        objWidget.render();
      }
    }

  }, {
    "./generator-widget": 4,
    "./weather-widget": 7
  }],
  7: [function (require, module, exports) {
    'use strict';

    Object.defineProperty(exports, "__esModule", {
      value: true
    });

    var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) {
      return typeof obj;
    } : function (obj) {
      return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj;
    };

    var _createClass = function () {
      function defineProperties(target, props) {
        for (var i = 0; i < props.length; i++) {
          var descriptor = props[i];
          descriptor.enumerable = descriptor.enumerable || false;
          descriptor.configurable = true;
          if ("value" in descriptor) descriptor.writable = true;
          Object.defineProperty(target, descriptor.key, descriptor);
        }
      }
      return function (Constructor, protoProps, staticProps) {
        if (protoProps) defineProperties(Constructor.prototype, protoProps);
        if (staticProps) defineProperties(Constructor, staticProps);
        return Constructor;
      };
    }();

    var _customDate = require('./custom-date');

    var _customDate2 = _interopRequireDefault(_customDate);

    var _graphicD3js = require('./graphic-d3js');

    var _graphicD3js2 = _interopRequireDefault(_graphicD3js);

    var _naturalPhenomenonData = require('./data/natural-phenomenon-data');

    var naturalPhenomenon = _interopRequireWildcard(_naturalPhenomenonData);

    var _windSpeedData = require('./data/wind-speed-data');

    var windSpeed = _interopRequireWildcard(_windSpeedData);

    var windDirection = _interopRequireWildcard(_windSpeedData);

    function _interopRequireWildcard(obj) {
      if (obj && obj.__esModule) {
        return obj;
      } else {
        var newObj = {};
        if (obj != null) {
          for (var key in obj) {
            if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key];
          }
        }
        newObj.default = obj;
        return newObj;
      }
    }

    function _interopRequireDefault(obj) {
      return obj && obj.__esModule ? obj : {
        default: obj
      };
    }

    function _classCallCheck(instance, Constructor) {
      if (!(instance instanceof Constructor)) {
        throw new TypeError("Cannot call a class as a function");
      }
    }

    function _possibleConstructorReturn(self, call) {
      if (!self) {
        throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
      }
      return call && (typeof call === "object" || typeof call === "function") ? call : self;
    }

    function _inherits(subClass, superClass) {
      if (typeof superClass !== "function" && superClass !== null) {
        throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
      }
      subClass.prototype = Object.create(superClass && superClass.prototype, {
        constructor: {
          value: subClass,
          enumerable: false,
          writable: true,
          configurable: true
        }
      });
      if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
    }
    /**
     * Created by Denis on 29.09.2016.
     */

    var WeatherWidget = function (_CustomDate) {
      _inherits(WeatherWidget, _CustomDate);

      function WeatherWidget(params, controls, urls) {
        _classCallCheck(this, WeatherWidget);

        var _this = _possibleConstructorReturn(this, (WeatherWidget.__proto__ || Object.getPrototypeOf(WeatherWidget)).call(this));

        _this.params = params;
        _this.controls = controls;
        _this.urls = urls;

        // Инициализируем объект пустыми значениями
        _this.weather = {
          fromAPI: {
            coord: {
              lon: '0',
              lat: '0'
            },
            weather: [{
              id: ' ',
              main: ' ',
              description: ' ',
              icon: ' '
            }],
            base: ' ',
            main: {
              temp: 0,
              pressure: ' ',
              humidity: ' ',
              temp_min: ' ',
              temp_max: ' '
            },
            wind: {
              speed: 0,
              deg: ' '
            },
            rain: {},
            clouds: {
              all: ' '
            },
            dt: '',
            sys: {
              type: ' ',
              id: ' ',
              message: ' ',
              country: ' ',
              sunrise: ' ',
              sunset: ' '
            },
            id: ' ',
            name: 'Undefined',
            cod: ' '
          }
        };
        return _this;
      }

      /**
       * Обертка обещение для асинхронных запросов
       * @param url
       * @returns {Promise}
       */


      _createClass(WeatherWidget, [{
        key: 'httpGet',
        value: function httpGet(url) {
          var that = this;
          return new Promise(function (resolve, reject) {
            var xhr = new XMLHttpRequest();
            xhr.onload = function () {
              if (xhr.status === 200) {
                resolve(JSON.parse(this.response));
              } else {
                var error = new Error(this.statusText);
                error.code = this.status;
                reject(that.error);
              }
            };

            xhr.ontimeout = function (e) {
              reject(new Error('Время ожидания обращения к серверу API истекло ' + e.type + ' ' + e.timeStamp.toFixed(2)));
            };

            xhr.onerror = function (e) {
              reject(new Error('Ошибка обращения к серверу ' + e));
            };

            xhr.open('GET', url, true);
            xhr.send(null);
          });
        }

        /**
         * Запрос к API для получения данных текущей погоды
         */

      }, {
        key: 'getWeatherFromApi',
        value: function getWeatherFromApi() {
          var _this2 = this;

          this.httpGet(this.urls.urlWeatherAPI).then(function (response) {
            _this2.weather.fromAPI = response;
            _this2.weather.naturalPhenomenon = naturalPhenomenon.naturalPhenomenon[_this2.params.lang].description;
            _this2.weather.windSpeed = windSpeed.windSpeed[_this2.params.lang];
            _this2.httpGet(_this2.urls.paramsUrlForeDaily).then(function (response) {
              _this2.weather.forecastDaily = response;
              _this2.parseDataFromServer();
            }, function (error) {
              console.log('Возникла ошибка ' + error);
              _this2.parseDataFromServer();
            });
          }, function (error) {
            console.log('Возникла ошибка ' + error);
            _this2.parseDataFromServer();
          });
        }

        /**
         * Метод возвращает родительский селектор по значению дочернего узла в JSON
         * @param {object} JSON
         * @param {variant} element Значение элементарного типа, дочернего узла для поиска родительского
         * @param {string} elementName Наименование искомого селектора,для поиска родительского селектора
         * @return {string} Наименование искомого селектора
         */

      }, {
        key: 'getParentSelectorFromObject',
        value: function getParentSelectorFromObject(object, element, elementName, elementName2) {
          for (var key in object) {
            // Если сравнение производится с объектом из двух элементов ввиде интервала
            if (_typeof(object[key][elementName]) === 'object' && elementName2 == null) {
              if (element >= object[key][elementName][0] && element < object[key][elementName][1]) {
                return key;
              }
              // сравнение производится со значением элементарного типа с двумя элементами в JSON
            } else if (elementName2 != null) {
              if (element >= object[key][elementName] && element < object[key][elementName2]) {
                return key;
              }
            }
          }
        }

        /**
         * Возвращает JSON с метеодаными
         * @param jsonData
         * @returns {*}
         */

      }, {
        key: 'parseDataFromServer',
        value: function parseDataFromServer() {
          var weather = this.weather;

          if (weather.fromAPI.name === 'Undefined' || weather.fromAPI.cod === '404') {
            console.log('Данные от сервера не получены');
            return;
          }

          // Инициализируем объект
          var metadata = {
            cloudiness: ' ',
            dt: ' ',
            cityName: ' ',
            icon: ' ',
            temperature: ' ',
            temperatureMin: ' ',
            temperatureMAx: ' ',
            pressure: ' ',
            humidity: ' ',
            sunrise: ' ',
            sunset: ' ',
            coord: ' ',
            wind: ' ',
            weather: ' '
          };
          var temperature = parseInt(weather.fromAPI.main.temp.toFixed(0), 10) + 0;
          metadata.cityName = weather.fromAPI.name + ', ' + weather.fromAPI.sys.country;
          metadata.temperature = temperature; // `${temp > 0 ? `+${temp}` : temp}`;
          metadata.temperatureMin = parseInt(weather.fromAPI.main.temp_min.toFixed(0), 10) + 0;
          metadata.temperatureMax = parseInt(weather.fromAPI.main.temp_max.toFixed(0), 10) + 0;
          if (weather.naturalPhenomenon) {
            metadata.weather = weather.naturalPhenomenon[weather.fromAPI.weather[0].id];
          }
          if (weather.windSpeed) {
            var windLabel = myWidgetParam.lang == "fr" ? 'Vent: ' : 'Wind: ';
            metadata.windSpeed = windLabel + weather.fromAPI.wind.speed.toFixed(1) + ' m/s ' + this.getParentSelectorFromObject(weather.windSpeed, weather.fromAPI.wind.speed.toFixed(1), 'speed_interval');
            metadata.windSpeed2 = weather.fromAPI.wind.speed.toFixed(1) + ' m/s';
          }
          if (weather.windDirection) {
            metadata.windDirection = '' + this.getParentSelectorFromObject(weather["windDirection"], weather["fromAPI"]["wind"]["deg"], "deg_interval");
          }
          if (weather.clouds) {
            metadata.clouds = '' + this.getParentSelectorFromObject(weather.clouds, weather.fromAPI.clouds.all, 'min', 'max');
          }

          metadata.humidity = weather.fromAPI.main.humidity + '%';
          metadata.pressure = weather["fromAPI"]["main"]["pressure"] + ' mb';
          metadata.icon = '' + weather.fromAPI.weather[0].icon;

          this.renderWidget(metadata);
        }
      }, {
        key: 'renderWidget',
        value: function renderWidget(metadata) {
          // Оотрисовка первых четырех виджетов
          for (var elem in this.controls.cityName) {
            if (this.controls.cityName.hasOwnProperty(elem)) {
              this.controls.cityName[elem].innerHTML = metadata.cityName;
            }
          }

          for (var _elem in this.controls.temperature) {
            if (this.controls.temperature.hasOwnProperty(_elem)) {
              this.controls.temperature[_elem].innerHTML = metadata.temperature + '<span class=\'weather-left-card__degree\'>' + this.params.textUnitTemp + '</span>';
            }
          }

          for (var _elem2 in this.controls.mainIconWeather) {
            if (this.controls.mainIconWeather.hasOwnProperty(_elem2)) {
              this.controls.mainIconWeather[_elem2].src = this.getURLMainIcon(metadata.icon, true);
              this.controls.mainIconWeather[_elem2].alt = 'Weather in ' + (metadata.cityName ? metadata.cityName : '');
            }
          }

          if (metadata.weather) {
            for (var _elem3 in this.controls.naturalPhenomenon) {
              if (this.controls.naturalPhenomenon.hasOwnProperty(_elem3)) {
                this.controls.naturalPhenomenon[_elem3].innerText = metadata.weather;
              }
            }
          }
          if (metadata.windSpeed) {
            for (var _elem4 in this.controls.windSpeed) {
              if (this.controls.windSpeed.hasOwnProperty(_elem4)) {
                this.controls.windSpeed[_elem4].innerText = metadata.windSpeed;
              }
            }
          }

          // Отрисовка пяти последних виджетов
          for (var _elem5 in this.controls.cityName2) {
            if (this.controls.cityName2.hasOwnProperty(_elem5)) {
              this.controls.cityName2[_elem5].innerHTML = metadata.cityName;
            }
          }

          for (var _elem6 in this.controls.temperature2) {
            if (this.controls.temperature2.hasOwnProperty(_elem6)) {
              this.controls.temperature2[_elem6].innerHTML = metadata.temperature + '<span>' + this.params.textUnitTemp + '</span>';
            }
            if (this.controls.temperatureFeels.hasOwnProperty(_elem6)) {
              this.controls.temperatureFeels[_elem6].innerHTML = metadata.temperature + '<span>' + this.params.textUnitTemp + '</span>';
            }
          }

          for (var _elem7 in this.controls.temperatureMin) {
            if (this.controls.temperatureMin.hasOwnProperty(_elem7)) {
              this.controls.temperatureMin[_elem7].innerHTML = metadata.temperature + '<span>' + this.params.textUnitTemp + '</span>';
            }
          }

          for (var _elem8 in this.controls.temperatureMax) {
            if (this.controls.temperatureMax.hasOwnProperty(_elem8)) {
              this.controls.temperatureMax[_elem8].innerHTML = metadata.temperature + '<span>' + this.params.textUnitTemp + '</span>';
            }
          }

          if (metadata.weather) {
            for (var _elem9 in this.controls.naturalPhenomenon2) {
              if (this.controls.naturalPhenomenon2.hasOwnProperty(_elem9)) {
                this.controls.naturalPhenomenon2[_elem9].innerText = metadata.weather;
              }
            }
          }

          if (metadata.windSpeed2 && metadata.windDirection) {
            for (var _elem10 in this.controls.windSpeed2) {
              if (this.controls.windSpeed2.hasOwnProperty(_elem10)) {
                this.controls.windSpeed2[_elem10].innerText = metadata.windSpeed2 + ' ' + metadata.windDirection;
              }
            }
          }

          for (var _elem11 in this.controls.mainIconWeather2) {
            if (this.controls.mainIconWeather2.hasOwnProperty(_elem11)) {
              this.controls.mainIconWeather2[_elem11].src = this.getURLMainIcon(metadata.icon, true);
              this.controls.mainIconWeather2[_elem11].alt = 'Weather in ' + (metadata.cityName ? metadata.cityName : '');
            }
          }

          if (metadata.humidity) {
            for (var _elem12 in this.controls.humidity) {
              if (this.controls.humidity.hasOwnProperty(_elem12)) {
                this.controls.humidity[_elem12].innerText = metadata.humidity;
              }
            }
          }

          if (metadata.pressure) {
            for (var _elem13 in this.controls.pressure) {
              if (this.controls.pressure.hasOwnProperty(_elem13)) {
                this.controls.pressure[_elem13].innerText = metadata.pressure;
              }
            }
          }

          // Прописываем текущую дату в виджеты
          for (var _elem14 in this.controls.dateReport) {
            if (this.controls.dateReport.hasOwnProperty(_elem14)) {
              this.controls.dateReport[_elem14].innerText = this.getTimeDateHHMMMonthDay();
            }
          }

          if (this.controls.graphic) {
            if (this.weather.forecastDaily) {
              this.prepareDataForGraphic();
            }
          }
        }
      }, {
        key: 'prepareDataForGraphic',
        value: function prepareDataForGraphic() {
          var arr = [];
          var todayLabel = myWidgetParam.lang == "fr" ? 'Auj' : 'Today';
          for (var elem in this.weather.forecastDaily.list) {
            var day = this.getDayNameOfWeekByDayNumber(this.getNumberDayInWeekByUnixTime(this.weather.forecastDaily.list[elem].dt));
            arr.push({
              min: Math.round(this.weather.forecastDaily.list[elem].temp.min),
              max: Math.round(this.weather.forecastDaily.list[elem].temp.max),
              day: elem != 0 ? day : todayLabel,
              icon: this.weather.forecastDaily.list[elem].weather[0].icon,
              date: this.timestampToDateTime(this.weather.forecastDaily.list[elem].dt)
            });
          }

          return this.drawGraphicD3(arr);
        }

        /**
         * Отрисовка названия дней недели и иконок с погодой
         * @param data
         */

      }, {
        key: 'renderIconsDaysOfWeek',
        value: function renderIconsDaysOfWeek(data) {
          var that = this;

          data.forEach(function (elem, index) {
            that.controls.calendarItem[index].innerHTML = elem.day + '<img src="http://openweathermap.org/img/w/' + elem.icon + '.png" width="32" height="32" alt="' + elem.day + '">';
          });
          return data;
        }
      }, {
        key: 'getURLMainIcon',
        value: function getURLMainIcon(nameIcon) {
          var color = arguments.length <= 1 || arguments[1] === undefined ? false : arguments[1];

          // Создаем и инициализируем карту сопоставлений
          var mapIcons = new Map();

          if (!color) {
            //
            mapIcons.set('01d', '01dbw');
            mapIcons.set('02d', '02dbw');
            mapIcons.set('03d', '03dbw');
            mapIcons.set('03d', '03dbw');
            mapIcons.set('04d', '04dbw');
            mapIcons.set('05d', '05dbw');
            mapIcons.set('06d', '06dbw');
            mapIcons.set('07d', '07dbw');
            mapIcons.set('08d', '08dbw');
            mapIcons.set('09d', '09dbw');
            mapIcons.set('10d', '10dbw');
            mapIcons.set('11d', '11dbw');
            mapIcons.set('13d', '13dbw');
            // Ночные
            mapIcons.set('01n', '01dbw');
            mapIcons.set('02n', '02dbw');
            mapIcons.set('03n', '03dbw');
            mapIcons.set('03n', '03dbw');
            mapIcons.set('04n', '04dbw');
            mapIcons.set('05n', '05dbw');
            mapIcons.set('06n', '06dbw');
            mapIcons.set('07n', '07dbw');
            mapIcons.set('08n', '08dbw');
            mapIcons.set('09n', '09dbw');
            mapIcons.set('10n', '10dbw');
            mapIcons.set('11n', '11dbw');
            mapIcons.set('13n', '13dbw');

            if (mapIcons.get(nameIcon)) {
              return this.params.baseURL + '/img/widgets/' + nameIcon + 'img/' + mapIcons.get(nameIcon) + '.png';
            }
            return 'http://openweathermap.org/img/w/' + nameIcon + '.png'; // Захардковежно до времен https
          }
          return this.params.baseURL + '/img/widgets/' + nameIcon + '.png';
        }

        /**
         * Отрисовка графика с помощью библиотеки D3
         */

      }, {
        key: 'drawGraphicD3',
        value: function drawGraphicD3(data) {
          this.renderIconsDaysOfWeek(data);

          // Параметризуем область отрисовки графика
          var params = {
            id: '#graphic',
            data: data,
            offsetX: 15,
            offsetY: 10,
            width: 420,
            height: 79,
            rawData: [],
            margin: 10,
            colorPolilyne: this.params.colorPolilyne,
            fontSize: '12px',
            fontColor: '#333',
            strokeWidth: '1px'
          };

          // Реконструкция процедуры рендеринга графика температуры
          var objGraphicD3 = new _graphicD3js2.default(params);
          objGraphicD3.render();
        }
      }, {
        key: 'render',
        value: function render() {
          this.getWeatherFromApi();
        }
      }]);

      return WeatherWidget;
    }(_customDate2.default);

    exports.default = WeatherWidget;

  }, {
    "./custom-date": 1,
    "./data/natural-phenomenon-data": 2,
    "./data/wind-speed-data": 3,
    "./graphic-d3js": 5
  }]
}, {}, [6])
;