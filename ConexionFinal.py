import mysql.connector
import psycopg2
import pyodbc
import random
import json
import datetime
from faker import Faker
from dataclasses import dataclass

fake = Faker('es_MX')

productos_base = ["Tornillo", "Cable Eléctrico", "Cemento", "Pintura", "Varilla", "Azulejo", "Tubo PVC"]

descriptores_producto = [
    "Industrial",
    "Premium",
    "Reforzado",
    "Profesional",
    "Galvanizado",
    "Flexible",
    "Exterior",
    "Interior",
    "Comercial",
    "Resistente"
]

tipos_posibles = ["Unidad", "Kilo", "Metro"]

marcas_ferreteria = [
    "Truper",
    "Pretul",
    "Bosch",
    "DeWalt",
    "Makita",
    "Cemex",
    "Cruz Azul"
]

categorias_ferreteria = [
    ("Herramientas Manuales", 1),
    ("Fontanería", 2),
    ("Electricidad", 3),
    ("Pinturas y Acabados", 4),
    ("Fijación y Tornillería", 5),
    ("Jardinería", 6),
    ("Herramienta Eléctrica", 7)
]

conceptos_gastos = [
    "Pago de Fletes y Acarreos",
    "Mantenimiento de Montacargas",
    "Servicios de Seguridad y Vigilancia",
    "Consumo de Energía Eléctrica",
    "Servicio de Internet y Telefonía",
    "Limpieza y Consumibles de Aseo",
    "Honorarios por Consultoría Contable",
    "Papelería y Artículos de Oficina",
    "Reparación de Estanterías"
]

@dataclass
class Venta:
    producto: str
    monto: float

def insertar_en_las_tres_db():

    id_cliente = 1
    id_prod = 1
    
    nueva_venta = Venta(
        producto=f"{random.choice(productos_base)} {random.choice(descriptores_producto)}",
        monto=round(random.uniform(15.0, 1200.0), 2)
    )

    nombre_emp = fake.company()

    rfc_emp = (
        fake.lexify(text='????').upper()
        + fake.date(pattern='%y%m%d')
        + fake.lexify(text='???').upper()
    )

    tipo_v = random.choice(tipos_posibles)

    cat_seleccionada, pasillo_seleccionado = random.choice(categorias_ferreteria)
    estado_p = random.choice(['Pendiente', 'Recibido'])
    
    ingresos = random.randint(5000, 20000)
    egresos = random.randint(1000, 5000)
    saldo = ingresos - egresos
    
    modulos_posibles = ['Ventas', 'Inventario', 'Usuarios', 'Cuentas_Cobrar', 'Nomina']
    acciones_posibles = ['Insert', 'Update', 'Delete', 'Login']

    modulo_sel = random.choice(modulos_posibles)
    accion_sel = random.choice(acciones_posibles)
    
    cantidad_vendida = random.randint(1, 20)
    
    if random.random() < 0.05:
        cantidad_vendida = 5
        nueva_venta.monto = 20.0

    stock_aleatorio = random.randint(0, 500)
    
    sueldo_aleatorio = random.randint(8000, 25000)
    bonos_aleatorios = random.randint(0, 3000)
    
    estado_pago_aleatorio = random.choice(['Pagado', 'Pendiente', 'Vencido'])
    
    concepto_seleccionado = random.choice(conceptos_gastos)
    
    capacidad_aleatoria = random.randint(50, 2000)

    if random.random() < 0.1:
        fecha_valida = datetime.date.today()
    else:
        fecha_valida = fake.date_between(
            start_date=datetime.date(2020, 1, 1),
            end_date='today'
        )

    detalles_dict = {
        "ip_responsable": fake.ipv4(),
        "usuario_sistema": fake.user_name(),
        "nivel": random.choice(["info", "alerta", "critico"])
    }

    detalles_json = json.dumps(detalles_dict)

    # --- 1. MYSQL ---
    try:
        cnx_mysql = mysql.connector.connect(
            user='admin',
            password='adminpassword',
            host='127.0.0.1',
            port=3306,
            database='punto_venta_db'
        )

        cursor = cnx_mysql.cursor()
        
        cursor.execute(
            "INSERT INTO clientes (nombre_completo, rfc, telefono, email) VALUES (%s, %s, %s, %s)",
            (
                fake.name(),
                rfc_emp,
                fake.msisdn()[:10],
                fake.email()
            )
        )

        id_cliente = cursor.lastrowid

        cursor.execute(
            "INSERT INTO categorias (nombre_categoria, pasillo) VALUES (%s, %s)",
            (
                cat_seleccionada,
                pasillo_seleccionado
            )
        )

        id_cat = cursor.lastrowid

        cursor.execute(
            "INSERT INTO productos (nombre, marca, id_categoria, precio_unitario, tipo_venta) VALUES (%s, %s, %s, %s, %s)",
            (
                nueva_venta.producto,
                random.choice(marcas_ferreteria),
                id_cat,
                nueva_venta.monto,
                tipo_v
            )
        )

        id_prod = cursor.lastrowid

        cursor.execute(
            "INSERT INTO ventas_mostrador (id_cliente, fecha_venta, total_venta) VALUES (%s, %s, %s)",
            (
                id_cliente,
                fecha_valida,
                round(nueva_venta.monto * cantidad_vendida, 2)
            )
        )

        id_venta = cursor.lastrowid

        cursor.execute(
            "INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, subtotal) VALUES (%s, %s, %s, %s)",
            (
                id_venta,
                id_prod,
                cantidad_vendida,
                round(nueva_venta.monto * cantidad_vendida, 2)
            )
        )
        
        cnx_mysql.commit()
        cnx_mysql.close()

    except Exception as e:
        print(f"❌ Error en MySQL: {e}")

    # --- 2. POSTGRESQL ---
    try:
        cnx_pg = psycopg2.connect(
            user='admin',
            password='adminpassword',
            host='127.0.0.1',
            port=5432,
            database='finanzas_auditoria_db'
        )

        cursor_pg = cnx_pg.cursor()
        
        cursor_pg.execute(
            "INSERT INTO gastos_sucursal (concepto, monto, fecha_gasto) VALUES (%s, %s, %s)",
            (
                concepto_seleccionado,
                nueva_venta.monto,
                fecha_valida
            )
        )

        cursor_pg.execute(
            "INSERT INTO cortes_caja (fecha_corte, ingresos_totales, egresos_totales, saldo_final) VALUES (%s, %s, %s, %s)",
            (
                fecha_valida,
                ingresos,
                egresos,
                saldo
            )
        )

        cursor_pg.execute(
            "INSERT INTO cuentas_por_cobrar (id_cliente_ref, monto_deuda, fecha_limite, estado_pago) VALUES (%s, %s, %s, %s)",
            (
                id_cliente,
                nueva_venta.monto,
                fecha_valida,
                estado_pago_aleatorio
            )
        )

        cursor_pg.execute(
            "INSERT INTO nomina_empleados (rfc_empleado, sueldo_pagado, fecha_pago, bonos) VALUES (%s, %s, %s, %s)",
            (
                rfc_emp,
                sueldo_aleatorio,
                fecha_valida,
                bonos_aleatorios
            )
        )
        
        cursor_pg.execute(
            "INSERT INTO log_auditoria (usuario, modulo, accion, fecha, detalles) VALUES (%s, %s, %s, %s, %s)",
            (
                fake.user_name(),
                modulo_sel,
                accion_sel,
                fecha_valida,
                detalles_json
            )
        )
        
        cnx_pg.commit()
        cnx_pg.close()

    except Exception as e:
        print(f"❌ Error en PostgreSQL: {e}")

    # --- 3. SQL SERVER ---
    try:
        conn_str = (
            'DRIVER={ODBC Driver 18 for SQL Server};'
            'SERVER=127.0.0.1,1433;'
            'DATABASE=inventario_logistica_db;'
            'UID=sa;'
            'PWD=AdminPassword123!;'
            'TrustServerCertificate=yes;'
        )

        cnx_sql = pyodbc.connect(conn_str)
        cursor_sql = cnx_sql.cursor()
        
        cursor_sql.execute(
            "INSERT INTO proveedores (razon_social, rfc_proveedor, telefono) VALUES (?, ?, ?)",
            (
                nombre_emp,
                rfc_emp[:13],
                fake.msisdn()[:10]
            )
        )

        id_prov = cursor_sql.execute("SELECT SCOPE_IDENTITY()").fetchval()

        cursor_sql.execute(
            "INSERT INTO almacenes (nombre_sucursal, capacidad_mts2) VALUES (?, ?)",
            (
                fake.city()[:75],
                capacidad_aleatoria
            )
        )

        id_alm = cursor_sql.execute("SELECT SCOPE_IDENTITY()").fetchval()

        cursor_sql.execute(
            "INSERT INTO lotes_inventario (id_producto_ref, id_proveedor, id_almacen, cantidad_stock, fecha_ingreso) VALUES (?, ?, ?, ?, ?)",
            (
                random.randint(1, 50),
                id_prov,
                id_alm,
                stock_aleatorio,
                fecha_valida
            )
        )

        cursor_sql.execute(
            "INSERT INTO pedidos_compra (id_proveedor, fecha_pedido, estado_pedido) VALUES (?, ?, ?)",
            (
                id_prov,
                fecha_valida,
                estado_p
            )
        )

        id_pedido = cursor_sql.execute("SELECT SCOPE_IDENTITY()").fetchval()
        
        cursor_sql.execute(
            "INSERT INTO detalle_pedidos (id_pedido, id_producto_ref, cantidad_solicitada, costo_unitario) VALUES (?, ?, ?, ?)",
            (
                id_pedido,
                random.randint(1, 50),
                random.randint(1, 100),
                random.randint(150, 500)
            )
        )
        
        cnx_sql.commit()
        cnx_sql.close()

    except Exception as e:
        print(f"❌ Error en SQL Server: {e}")

if __name__ == "__main__":
    print("Iniciando inserción de 50 registros por tabla...\n")

    for i in range(50):
        insertar_en_las_tres_db()
    
    print("✅ MySQL: Datos guardados correctamente")
    print("✅ PostgreSQL: Dato guardado")
    print("✅ SQL Server: Dato guardado")