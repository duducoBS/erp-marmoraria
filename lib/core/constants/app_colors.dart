import 'package:flutter/material.dart';

class AppColors {
  // Cores Primárias e Secundárias
  static const Color primary = Color(0xFF1E293B); // Slate Blue escuro (Mármore Nero / Ardósia)
  static const Color primaryLight = Color(0xFF334155);
  static const Color primaryDark = Color(0xFF0F172A);

  static const Color secondary = Color(0xFFD97706); // Dourado Mármore Travertino / Âmbar
  static const Color secondaryLight = Color(0xFFF59E0B);

  static const Color accent = Color(0xFF0284C7); // Azul Técnico
  static const Color success = Color(0xFF059669); // Verde Esmeralda (Aprovado / Concluído)
  static const Color warning = Color(0xFFEAB308); // Amarelo Alerta
  static const Color danger = Color(0xFFDC2626); // Vermelho Coral (Recusado / Vencido)
  static const Color info = Color(0xFF2563EB); // Azul Informativo

  // Neutras e Superfícies (Modo Claro)
  static const Color background = Color(0xFFF8FAFC); // Fundo cinza suave tipo mármore claro
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Neutras e Superfícies (Modo Escuro)
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B); // Slate 500

  // Cores para as fases do Kanban
  static const Color kanbanMedicao = Color(0xFF6366F1); // Indigo
  static const Color kanbanCorte = Color(0xFFF59E0B); // Laranja / Âmbar
  static const Color kanbanAcabamento = Color(0xFF8B5CF6); // Roxo
  static const Color kanbanMontagem = Color(0xFF0EA5E9); // Azul Claro
  static const Color kanbanConcluido = Color(0xFF10B981); // Verde

  // Helpers de cores com base no tema ativo (Modo Claro vs Modo Escuro)
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color surfaceVariantOf(BuildContext context) =>
      isDark(context) ? darkSurfaceVariant : surfaceVariant;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? darkTextPrimary : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;

  static Color textMutedOf(BuildContext context) =>
      isDark(context) ? darkTextMuted : textMuted;

  static Color primaryIconOf(BuildContext context) =>
      isDark(context) ? secondaryLight : primary;

  static Color priceColorOf(BuildContext context) =>
      isDark(context) ? const Color(0xFF38BDF8) : primary;
}
