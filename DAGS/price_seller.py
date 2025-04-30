from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

default_args = {
    'owner': 'etl_client',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='insert_price_change_and_seller_info',
    default_args=default_args,
    description='Daily insert of price change and seller information',
    schedule_interval='55 6 * * *',
    start_date=days_ago(1),
    catchup=False,
    max_active_runs=1,
    tags=['daily', 'price_change', 'seller_info'],
) as dag:

    insert_price_change = BashOperator(
        task_id='insert_price_change',
        bash_command="""
        set -e
        sleep 5;
        cp /scripts/1_insert_price_change.sql /tmp/tmp_price.sql;
        sed -i "s/__DATE_RAW__/$(date +%d%m%Y)/g" /tmp/tmp_price.sql;
        sed -i "s/__DATE__/$(date +%Y-%m-%d)/g" /tmp/tmp_price.sql;
        PGPASSWORD={{ var.value.db_password }} psql -h {{ var.value.db_host }} -U etl_client -d reality_data -p 5432 -f /tmp/tmp_price.sql;
        rm -f /tmp/tmp_price.sql
        """
    )

    insert_seller_info = BashOperator(
        task_id='insert_seller_info',
        bash_command="""
        set -e
        sleep 5;
        cp /scripts/2_insert_seller_info.sql /tmp/tmp_seller.sql;
        sed -i "s/__DATE_RAW__/$(date +%d%m%Y)/g" /tmp/tmp_seller.sql;
        sed -i "s/__DATE__/$(date +%Y-%m-%d)/g" /tmp/tmp_seller.sql;
        PGPASSWORD={{ var.value.db_password }} psql -h {{ var.value.db_host }} -U etl_client -d reality_data -p 5432 -f /tmp/tmp_seller.sql;
        rm -f /tmp/tmp_seller.sql
        """
    )

    insert_price_change >> insert_seller_info