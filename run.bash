#!/usr/bin/env bash
set -euo pipefail

# ===== טסטים להרצה =====
TESTS=(
  reset_test
  basic_test
  # הוסיפי כאן עוד
)

# כמה במקביל
JOBS=${JOBS:-2}

mkdir -p logs acdb reports sims

echo "[INFO] Compile step (with UVM) ..."

# ניקוי קומפילציה קודמת
rm -rf work* *.lib library.cfg sims/* || true

# יצירת work
vlib work

# נסיון "הדרך הנכונה" בריביירה: -uvm (טוען/מפעיל UVM)
# אם יש filelist של EP – נשתמש בו
if [[ -f compile_sv.f ]]; then
  vlog -sv -uvm -dbg -f compile_sv.f
else
  vlog -sv -uvm -dbg *.sv
fi

echo "[INFO] Spawning simulations ..."

run_one() {
  local t="$1"
  local simdir="sims/$t"
  mkdir -p "$simdir"

  # בידוד ספרייה לכל ריצה כדי שלא ידרסו אחד את השני במקביל
  if [[ -d work.lib ]]; then
    cp -r work.lib "$simdir/work.lib"
  elif [[ -d work ]]; then
    cp -r work "$simdir/work"
  fi
  [[ -f library.cfg ]] && cp library.cfg "$simdir/library.cfg"

  (
    cd "$simdir"

    # בדיוק כמו שהעלית – רק מוסיפים -L uvm כדי לקשר לספריית UVM אם קיימת
    vsim -c -acdb +access+r +UVM_TESTNAME="$t" -L uvm tb_top \
      -l "../../logs/${t}.log" \
      -do "run -all;
           acdb save -o ../../acdb/${t}.acdb;
           acdb report -db ../../acdb/${t}.acdb -txt -o ../../reports/${t}.txt;
           exec cat ../../reports/${t}.txt;
           exit"
  )
}

active=0
for t in "${TESTS[@]}"; do
  echo "==> $t"
  run_one "$t" &
  active=$((active+1))
  if [[ "$active" -ge "$JOBS" ]]; then
    wait -n
    active=$((active-1))
  fi
done
wait

echo "[DONE] All tests finished."
