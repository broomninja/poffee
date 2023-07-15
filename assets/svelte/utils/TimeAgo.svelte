<script lang="ts">

  import { readable } from 'svelte/store';

  const time = readable(new Date().getTime(), function start(set) {
    const interval = setInterval(() => {
      set(new Date().getTime());
    }, 1000);

    return function stop() {
      clearInterval(interval);
    };
  });

  /**
   * @description Date should be a valid Date object, a valid UNIX timestamp or a valid date string, preferably in ISO-8601 format.
   * @default new Date().getTime()
   * @type {(number|string|Date)}
   */
  export let date:number|string|Date = new Date().getTime();

  /**
   * @description Should the displayed time update every 1 second?
   * @default false
   */
  export let live:boolean = false;
  
  /**
   * @description Should the word ago be displayed after the time?
   * @default true
   */
  export let withSuffix:boolean = true;

  /**
   * @description The suffix used when `withSuffix` is set to true.
   * @default 'ago'
   */
  export let suffix:string = ' ago';

  /**
   * @description Should the suffix be a prefix? Useful for some languages like French. i.e. 'il y à {n}{unit}'
   */
  export let asPrefix:boolean = false;

  /**
   * @description The units to be displayed. Can also be used to set your own locale. i.e. 秒、分、時間 etc.
   * @default {seconds:'seconds',minutes:'minutes',hours:'hours',days:'days',months:'months',years:'years'}
   */
  export let units:IUnits = {seconds:'seconds',minutes:'minutes',hours:'hours',days:'days',months:'months',years:'years'};
  export let singleUnits:IUnits = {seconds:'second',minutes:'minute',hours:'hour',days:'day',months:'month',years:'year'};

  /**
   * @description This is just a fallback for properties not passed in the `units` prop.
   */
  const __units = {
              seconds:'seconds',
              minutes:'minutes',
              hours:'hours',
              days:'days',
              months:'months',
              years:'years'
            }
  
  const __singleUnits = {
            seconds:'second',
            minutes:'minute',
            hours:'hour',
            days:'day',
            months:'month',
            years:'year'
          }

  let now = new Date().getTime();
  $: asDate = (typeof date == 'number') ? (date.toString().length==10) ? new Date(date*1000).getTime() : new Date(date).getTime() : new Date(date).getTime();
  $: diff = (live==true) ? $time - asDate : now - asDate;
  $: seconds = diff/1000;
  $: minutes = seconds/60;
  $: hours = minutes/60;
  $: days = hours/24;
  $: months = days/30;
  $: years = months/12;
  $: unit = (seconds<60) ? 'seconds' : (minutes<60) ? 'minutes' : (hours<24) ? 'hours' : (days<31) ? 'days' : (months<12) ? 'months' : 'years';
  $: obj = {seconds:seconds,minutes:minutes,hours:hours,days:days,months:months,years:years};
  
  interface IUnits {
    seconds?:string,
    minutes?:string,
    hours?:string,
    days?:string,
    months?:string,
    years?:string
  }

  const getUnitLabel = (value, unitName) => {
    return value == 1 ? singleUnits[unitName] ?? __singleUnits[unitName] : units[unitName] ?? __units[unitName]; 
  }

</script>
{#if withSuffix && asPrefix}{suffix}{/if}{parseInt(obj[unit])} {getUnitLabel(parseInt(obj[unit]), unit)}{#if withSuffix && !asPrefix}{suffix}{/if}