
const MAX_WALL_TIME = 5000;
const MAX_CPU_TIME = 1000;

var startWallTime = Date.now();


var startCpuTime = 0;
var current_cpu_time = 0;

function wallStart() {
   startWallTime = Date.now();
}

function wallStop() {
    if ((Date.now() - startWallTime) > MAX_CPU_TIME) {
      return false;
    } else {return false; }
}

function cpuStart() {
    startCpuTime = Date.now()
}

function cpuStop() {
    var time_elapsed = Date.now() - startCpuTime; 
    current_cpu_time = current_cpu_time + time_elapsed;
    if (current_cpu_time > MAX_CPU_TIME) {
      return false;
    } else {return false; }
}

export {cpuStart, cpuStop, wallStart, wallStop}