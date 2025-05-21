from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'reality_client',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def print_table_check():
    print("Checking if today's table exists...")

with DAG(
    dag_id='combined_daily_full_process',
    default_args=default_args,
    description='Daily ETL: snemovitosti, beznemovitosti, hypernemovitosti, dnesnemovitosti',
    schedule_interval='50 6 * * *',
    start_date=datetime(2025, 4, 18),
    catchup=False,
    max_active_runs=1,
    tags=['daily', 'sql', 'etl', 'real_estate'],
) as dag:

    check_today_table = PythonOperator(
        task_id='check_today_table',
        python_callable=print_table_check,
    )

    # ---- SNEMOVITOSTI pipeline ----
    run_sql_script_1 = BashOperator(
        task_id='insert_snemovitosti',
        bash_command="""
sleep 5
cp /scripts/1_insert_snemovitosti.sql /tmp/tmp_1.sql
sed -i "s/__DATE__/$(date +%Y-%m-%d)/g" /tmp/tmp_1.sql
sed -i "s/__DATE_RAW__/$(date +%d%m%Y)/g" /tmp/tmp_1.sql
PGPASSWORD={{ var.value.db_password }} psql -h {{ var.value.db_host }} -U reality_client -d reality_data -p 5432 -f /tmp/tmp_1.sql
""",
    )
    run_sql_script_2 = BashOperator(
        task_id='archive_missing_snemovitosti',
        bash_command="""
sleep 5
cp /scripts/2_deactivate_missing_snemovitosti.sql /tmp/tmp_2.sql
sed -i "s/__DATE__/$(date +%Y-%m-%d)/g" /tmp/tmp_2.sql
sed -i "s/__DATE_RAW__/$(date +%d%m%Y)/g" /tmp/tmp_2.sql
PGPASSWORD={{ var.value.db_password }} psql -h {{ var.value.db_host }} -U reality_client -d reality_data -p 5432 -f /tmp/tmp_2.sql
""",
    )
    run_sql_script_3 = BashOperator(
        task_id='reactivate_snemovitosti',
        bash_command="""
sleep 5
cp /scripts/3_reactivate_returned_snemovitosti.sql /tmp/tmp_3.sql
sed -i "s/__DATE__/$(date +%Y-%m-%d)/g" /tmp/tmp_3.sql
sed -i "s/__DATE_RAW__/$(date +%d%m%Y)/g" /tmp/tmp_3.sql
PGPASSWORD={{ var.value.db_password }} psql -h {{ var.value.db_host }} -U reality_client -d reality_data -p 5432 -f /tmp/tmp_3.sql
""",
    )
    run_sql_script_4 = BashOperator(
        task_id='insert_meta_snemovitosti',
        bash_command="""
sleep 5
cp /scripts/4_insert_meta_snemovitosti.sql /tmp/tmp_4.sql
sed -i "s/__DATE__/$(date +%Y-%m-%d)/g" /tmp/tmp_4.sql
sed -i "s/__DATE_RAW__/$(date +%d%m%Y)/g" /tmp/tmp_4.sql
PGPASSWORD={{ var.value.db_password }} psql -h {{ var.value.db_host }} -U reality_client -d reality_data -p 5432 -f /tmp/tmp_4.sql
""",
    )
    run_sql_script_5 = BashOperator(
        task_id='insert_images_snemovitosti',
        bash_command="""
sleep 5
cp /scripts/5_insert_images_snemovitosti.sql /tmp/tmp_5.sql
sed -i "s/__DATE__/$(date +%Y-%m-%d)/g" /tmp/tmp_5.sql
sed -i "s/__DATE_RAW__/$(date +%d%m%Y)/g" /tmp/tmp_5.sql
PGPASSWORD={{ var.value.db_password }} psql -h {{ var.value.db_host }} -U reality_client -d reality_data -p 5432 -f /tmp/tmp_5.sql
""",

    check_today_table >> run_sql_script_1 >> run_sql_script_2 >> run_sql_script_3 >> run_sql_script_4 >> run_sql_script_5
