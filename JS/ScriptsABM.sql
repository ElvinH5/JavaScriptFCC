DECLARE @maxId INT
DECLARE @cod_submodulo_padre INT, @cod_submodulo_max INT 
DECLARE @max_via_modulo_padre INT
DECLARE @nro_orden INT 

DECLARE @cod_modulo INT 
DECLARE @txt_nombre_abm VARCHAR(100) = 'Redes'
DECLARE @txt_nombre_tabla VARCHAR(100) = 'redes_caja_empresarial'


SELECT @cod_modulo=cod_modulo FROM tmodulo_sistema where txt_desc='Seguridad' AND sn_web=-1

SELECT @cod_submodulo_padre=cod_submodulo 
FROM tsubmodulo
WHERE  txt_desc='Caja Empresarial'
AND cod_modulo=@cod_modulo;


SELECT @cod_submodulo_max = MAX(cod_submodulo) + 1 FROM tsubmodulo where cod_modulo = @cod_modulo
IF(@cod_modulo is not null and @cod_submodulo_padre is not null)
BEGIN
IF NOT EXISTS (SELECT 1 FROM tabm_dinamico WHERE txt_nombre_tabla = @txt_nombre_tabla AND txt_nombre_abm=@txt_nombre_abm)
	BEGIN
		SELECT @maxId = MAX(id_abm) + 1 FROM tabm_dinamico
		INSERT INTO tabm_dinamico
		(
		id_abm,
		cod_modulo,
		cod_submodulo,
		txt_nombre_abm,
		txt_nombre_tabla,
		txt_nombre_sp_grilla,
		txt_nombre_sp_alta,
		txt_nombre_sp_mod,
		txt_nombre_sp_delete,
		txt_nombre_sp_leer,
		sn_importacion
		)
		VALUES(@maxId,@cod_modulo,@cod_submodulo_max,@txt_nombre_abm,@txt_nombre_tabla,
		'usp_cargar_abm_red_c_empre_core', 
		'usp_insert_abm_red_c_empre_core',
		'usp_modif_abm_red_c_empre_core',
		'usp_eliminar_abm_red_c_empre_core',
		'usp_leer_abm_red_c_empre_core',0)

		IF NOT EXISTS (SELECT 1 FROM tabm_dinamico_columna WHERE id_abm = @maxId) BEGIN
			INSERT INTO dbo.tabm_dinamico_columna (id_abm, id_columna, txt_nombre_columna, txt_tipo_dato, txt_sql, nro_orden, sn_requerido, sn_key, sn_readonly, sn_inhabilitar_modificar)
			VALUES (@maxId, 1, 'Ramo', 'combo', 'SELECT cod_ramo AS ID, txt_desc AS DESCRIPTION FROM tramo WHERE sn_habilitado = -1 AND sn_ramo_comercial = -1', 1, -1, -1, 0, -1);
			
			INSERT INTO dbo.tabm_dinamico_columna (id_abm, id_columna, txt_nombre_columna, txt_tipo_dato, txt_sql, nro_orden, sn_requerido, sn_key, sn_readonly, sn_inhabilitar_modificar)
			VALUES (@maxId, 2, 'Sucursal', 'combo', 'SELECT cod_suc AS ID, txt_nom_suc AS DESCRIPTION FROM tsuc', 2, -1, -1, 0, -1);
			
			INSERT INTO dbo.tabm_dinamico_columna (id_abm, id_columna, txt_nombre_columna, txt_tipo_dato, txt_sql, nro_orden, sn_requerido, sn_key, sn_readonly, sn_inhabilitar_modificar)
			VALUES (@maxId, 3, 'Excluir', 'combo', 'SELECT -1 AS ID, ''SI'' AS DESCRIPTION UNION ALL SELECT 0 AS ID, ''NO'' AS DESCRIPTION', 3, 0, 0, 0, 0);
			
			INSERT INTO dbo.tabm_dinamico_columna (id_abm, id_columna, txt_nombre_columna, txt_tipo_dato, txt_sql, nro_orden, sn_requerido, sn_key, sn_readonly, sn_inhabilitar_modificar)
			VALUES (@maxId, 4, 'Póliza', 'numeric', NULL, 4, -1, -1, 0, -1);
			
			INSERT INTO dbo.tabm_dinamico_columna (id_abm, id_columna, txt_nombre_columna, txt_tipo_dato, txt_sql, nro_orden, sn_requerido, sn_key, sn_readonly, sn_inhabilitar_modificar)
			VALUES (@maxId, 5, 'Fecha Suspensión', 'shortdatetime', NULL, 5, 0, 0, 0, 0);
			
			INSERT INTO dbo.tabm_dinamico_columna (id_abm, id_columna, txt_nombre_columna, txt_tipo_dato, txt_sql, nro_orden, sn_requerido, sn_key, sn_readonly, sn_inhabilitar_modificar)
			VALUES (@maxId, 6, 'Usuario', 'username', NULL, 6, 0, 0, -1, -1);

		END
		


-- Inicio de creacion de un submenu
		IF NOT EXISTS (SELECT 1 FROM tsubmodulo WHERE cod_modulo = @cod_modulo AND txt_desc = 'Exclusión')
			BEGIN
					INSERT INTO tsubmodulo
					(
					cod_modulo,
					cod_submodulo,
					txt_desc,
					id_cod_submodulo_padre
					)
					VALUES(@cod_modulo,@cod_submodulo_max ,'Exclusión',@cod_submodulo_padre)	

				IF NOT EXISTS (SELECT 1 FROM tsubmodulo_sistema WHERE cod_modulo = @cod_modulo AND cod_submodulo = @cod_submodulo_max )
					INSERT INTO tsubmodulo_sistema
					(
					cod_modulo,
					cod_submodulo,
					txt_desc,
					txt_nombre,
					submodulo_fecha,
					submodulo_size,
					sn_search,
					sn_visible
					)
					VALUES(@cod_modulo,@cod_submodulo_max ,'Exclusión','/dynamiccrud/dynamiccrud?codModulo='+ CAST(@cod_modulo AS varchar)+'&codSubModulo=' + CAST(@cod_submodulo_max  AS varchar) + '&idCrud=' + CAST(@maxId AS varchar),GETDATE(),0,0,-1)

				IF NOT EXISTS (SELECT 1 FROM tsubmodulo_orden WHERE cod_modulo = @cod_modulo AND cod_submodulo = @cod_submodulo_max )
				BEGIN  
					SELECT @max_via_modulo_padre = max(cod_submodulo)-1 
					FROM tsubmodulo 
					WHERE id_cod_submodulo_padre = @cod_submodulo_padre 
					AND cod_modulo = @cod_modulo
	
	 
					SELECT @nro_orden=MAX(norden)+1
					FROM tsubmodulo_orden
					WHERE cod_modulo=@cod_modulo
					AND cod_submodulo=@max_via_modulo_padre	
					PRINT @max_via_modulo_padre
					
					INSERT INTO tsubmodulo_orden
					(
					cod_modulo,
					cod_submodulo,
					norden
					)
					VALUES(@cod_modulo,@cod_submodulo_max ,@nro_orden)

					INSERT INTO tpermiso_submodulo (
						cod_modulo
						, cod_submodulo
						, cod_rol
						, permite_todo)        
					SELECT DISTINCT @cod_modulo, @cod_submodulo_max, cod_rol,permite_todo         
					FROM tpermiso_submodulo 
					WHERE cod_modulo = @cod_modulo and cod_submodulo = @cod_submodulo_padre 
						AND NOT EXISTS(SELECT TOP 1 * FROM tpermiso_submodulo WHERE cod_modulo = @cod_modulo AND cod_submodulo = @cod_submodulo_max AND cod_rol = tpermiso_submodulo.cod_rol)
				END 
			END

	END
END
