
-- para criar e setar o DB 
CREATE DATABASE IF NOT EXISTS `cimow_db`
USE `cimow_db`;

--
-- Estrutura da tabela `Usuarios`
--

CREATE TABLE `Usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificador único do usuário (PK)',
  `nome` varchar(255) NOT NULL COMMENT 'Nome completo do usuário',
  `cpf` varchar(14) NOT NULL COMMENT 'CPF do usuário, deve ser único',
  `email` varchar(255) NOT NULL COMMENT 'Endereço de e-mail do usuário, deve ser único',
  `senha` varchar(255) NOT NULL COMMENT 'Senha do usuário, armazenada em formato hash',
  `data_nascimento` date NOT NULL COMMENT 'Data de nascimento do usuário',
  `telefone` varchar(20) DEFAULT NULL COMMENT 'Número de telefone de contato do usuário',
  `tipo_usuario` enum('paciente','medico','admin') NOT NULL COMMENT 'Define o perfil de acesso do usuário (paciente, medico, admin)',
  `status` enum('ativo','inativo') NOT NULL DEFAULT 'ativo' COMMENT 'Status da conta do usuário (ativa ou inativa)',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Data e hora de criação do registro',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Data e hora da última atualização do registro',
  PRIMARY KEY (`id`),
  UNIQUE KEY `cpf` (`cpf`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabela central para armazenar informações de todos os usuários do sistema.';

--
-- Estrutura da tabela `LogsAtividades`
--

CREATE TABLE `LogsAtividades` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Identificador único do log (PK)',
  `usuario_id` int(11) DEFAULT NULL COMMENT 'ID do usuário que realizou a ação (FK de Usuarios)',
  `acao` varchar(255) NOT NULL COMMENT 'Ação realizada pelo usuário (ex: login, logout, agendamento)',
  `descricao` text DEFAULT NULL COMMENT 'Descrição detalhada da atividade registrada',
  `data_hora` timestamp NULL DEFAULT current_timestamp() COMMENT 'Data e hora em que a ação ocorreu',
  PRIMARY KEY (`id`),
  KEY `idx_logsatividades_usuario_id` (`usuario_id`),
  CONSTRAINT `LogsAtividades_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `Usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registra as atividades importantes realizadas pelos usuários no sistema.';

--
-- Estrutura da tabela `Medicos`
--

CREATE TABLE `Medicos` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificador único do médico (PK)',
  `usuario_id` int(11) NOT NULL COMMENT 'ID do usuário correspondente na tabela Usuarios (FK)',
  `crm` varchar(20) NOT NULL COMMENT 'Registro do Conselho Regional de Medicina, deve ser único',
  `especialidade` varchar(100) NOT NULL COMMENT 'Especialidade principal do médico',
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario_id` (`usuario_id`),
  UNIQUE KEY `crm` (`crm`),
  CONSTRAINT `Medicos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `Usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Armazena informações específicas dos profissionais médicos.';

--
-- Estrutura da tabela `Pacientes`
--

CREATE TABLE `Pacientes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificador único do paciente (PK)',
  `usuario_id` int(11) NOT NULL COMMENT 'ID do usuário correspondente na tabela Usuarios (FK)',
  `historico_medico` text DEFAULT NULL COMMENT 'Resumo do histórico médico do paciente',
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `Pacientes_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `Usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Armazena informações específicas dos pacientes.';

--
-- Estrutura da tabela `Consultas`
--

CREATE TABLE `Consultas` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificador único da consulta (PK)',
  `paciente_id` int(11) NOT NULL COMMENT 'ID do paciente associado à consulta (FK de Pacientes)',
  `medico_id` int(11) NOT NULL COMMENT 'ID do médico responsável pela consulta (FK de Medicos)',
  `data_hora` datetime NOT NULL COMMENT 'Data e hora agendada para a consulta',
  `status` enum('agendada','realizada','cancelada') NOT NULL DEFAULT 'agendada' COMMENT 'Status atual da consulta',
  `tipo_consulta` enum('online','presencial') NOT NULL COMMENT 'Modalidade da consulta (online ou presencial)',
  `link_atendimento` varchar(255) DEFAULT NULL COMMENT 'Link para a teleconsulta, se aplicável',
  `observacoes` text DEFAULT NULL COMMENT 'Observações adicionais sobre o agendamento da consulta',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Data e hora de criação do registro da consulta',
  PRIMARY KEY (`id`),
  KEY `idx_consultas_paciente_id` (`paciente_id`),
  KEY `idx_consultas_medico_id` (`medico_id`),
  KEY `idx_consultas_data_hora` (`data_hora`),
  CONSTRAINT `Consultas_ibfk_1` FOREIGN KEY (`paciente_id`) REFERENCES `Pacientes` (`id`),
  CONSTRAINT `Consultas_ibfk_2` FOREIGN KEY (`medico_id`) REFERENCES `Medicos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Armazena informações sobre os agendamentos de consultas.';

--
-- Estrutura da tabela `Prontuarios`
--

CREATE TABLE `Prontuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificador único do prontuário (PK)',
  `consulta_id` int(11) NOT NULL COMMENT 'ID da consulta que originou este prontuário (FK de Consultas)',
  `paciente_id` int(11) NOT NULL COMMENT 'ID do paciente a quem o prontuário pertence (FK de Pacientes)',
  `medico_id` int(11) NOT NULL COMMENT 'ID do médico que criou o prontuário (FK de Medicos)',
  `anotacoes_medicas` text NOT NULL COMMENT 'Anotações detalhadas feitas pelo médico durante a consulta',
  `diagnostico` text DEFAULT NULL COMMENT 'Diagnóstico do médico para o paciente',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Data e hora de criação do prontuário',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Data e hora da última atualização do prontuário',
  PRIMARY KEY (`id`),
  UNIQUE KEY `consulta_id` (`consulta_id`),
  KEY `idx_prontuarios_paciente_id` (`paciente_id`),
  KEY `idx_prontuarios_medico_id` (`medico_id`),
  CONSTRAINT `Prontuarios_ibfk_1` FOREIGN KEY (`consulta_id`) REFERENCES `Consultas` (`id`),
  CONSTRAINT `Prontuarios_ibfk_2` FOREIGN KEY (`paciente_id`) REFERENCES `Pacientes` (`id`),
  CONSTRAINT `Prontuarios_ibfk_3` FOREIGN KEY (`medico_id`) REFERENCES `Medicos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registros médicos eletrônicos gerados a partir de cada consulta.';

--
-- Estrutura da tabela `Prescricoes`
--

CREATE TABLE `Prescricoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificador único da prescrição (PK)',
  `prontuario_id` int(11) NOT NULL COMMENT 'ID do prontuário ao qual esta prescrição está vinculada (FK de Prontuarios)',
  `medicamento` varchar(255) NOT NULL COMMENT 'Nome do medicamento prescrito',
  `dosagem` varchar(100) NOT NULL COMMENT 'Dosagem recomendada do medicamento (ex: 500mg)',
  `frequencia` varchar(100) NOT NULL COMMENT 'Frequência de uso (ex: de 8 em 8 horas)',
  `duracao_tratamento` varchar(100) DEFAULT NULL COMMENT 'Duração do tratamento (ex: 7 dias)',
  `instrucoes_adicionais` text DEFAULT NULL COMMENT 'Instruções extras para o paciente sobre o uso do medicamento',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Data e hora da emissão da prescrição',
  PRIMARY KEY (`id`),
  KEY `idx_prescricoes_prontuario_id` (`prontuario_id`),
  CONSTRAINT `Prescricoes_ibfk_1` FOREIGN KEY (`prontuario_id`) REFERENCES `Prontuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Armazena as prescrições médicas associadas a um prontuário.';
