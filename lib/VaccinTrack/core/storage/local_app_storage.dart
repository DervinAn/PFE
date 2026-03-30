import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/child_entity.dart';
import '../../domain/entities/child_vaccination_entity.dart';
import '../../domain/entities/guidance_article_entity.dart';
import '../../domain/entities/planned_vaccine_dose_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/vaccine_entity.dart';

class LocalAppStorage {
  LocalAppStorage._();
  static final LocalAppStorage instance = LocalAppStorage._();

  SharedPreferences? _prefs;

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserPassword = 'user_password';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyChildren = 'children_profiles';
  static const String _keyChildVaccinations = 'child_vaccinations';
  static const String _keyActiveChildId = 'active_child_id';
  static const String _keyReadNotificationIds = 'notification_read_ids';
  static const String _keyDismissedNotificationIds =
      'notification_dismissed_ids';
  static const String _keyGuidanceRemarks = 'guidance_remarks';

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> isOnboardingCompleted() async {
    await init();
    return _prefs!.getBool(_keyOnboardingCompleted) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await init();
    await _prefs!.setBool(_keyOnboardingCompleted, value);
  }

  Future<bool> isLoggedIn() async {
    await init();
    return _prefs!.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<bool> hasSavedAccount() async {
    await init();
    final email = _prefs!.getString(_keyUserEmail);
    final password = _prefs!.getString(_keyUserPassword);
    return email != null &&
        email.trim().isNotEmpty &&
        password != null &&
        password.isNotEmpty;
  }

  Future<void> setLoggedIn(bool value) async {
    await init();
    await _prefs!.setBool(_keyIsLoggedIn, value);
  }

  Future<void> saveUser({
    required String fullName,
    required String email,
    String? phone,
    required String password,
  }) async {
    await init();
    await _prefs!.setString(_keyUserName, fullName);
    await _prefs!.setString(_keyUserEmail, email.toLowerCase());
    await _prefs!.setString(_keyUserPhone, phone ?? '');
    await _prefs!.setString(_keyUserPassword, password);
    await _prefs!.setBool(_keyNotificationsEnabled, true);
    // New account starts with its own local dataset.
    await _prefs!.remove(_keyChildren);
    await _prefs!.remove(_keyChildVaccinations);
    await _prefs!.remove(_keyReadNotificationIds);
    await _prefs!.remove(_keyDismissedNotificationIds);
    await _prefs!.remove(_keyGuidanceRemarks);
    await _prefs!.remove(_keyActiveChildId);
  }

  Future<bool> emailExists(String email) async {
    await init();
    final savedEmail = _prefs!.getString(_keyUserEmail);
    if (savedEmail == null || savedEmail.isEmpty) return false;
    return savedEmail.trim().toLowerCase() == email.trim().toLowerCase();
  }

  Future<bool> login({required String email, required String password}) async {
    await init();
    final savedEmail = _prefs!.getString(_keyUserEmail);
    final savedPassword = _prefs!.getString(_keyUserPassword);
    if (savedEmail == null || savedPassword == null) {
      return false;
    }
    final ok =
        savedEmail.trim().toLowerCase() == email.trim().toLowerCase() &&
        savedPassword == password;
    if (ok) {
      await _prefs!.setBool(_keyIsLoggedIn, true);
    }
    return ok;
  }

  Future<Map<String, String>> getSignedInUser() async {
    await init();
    final name = _prefs!.getString(_keyUserName)?.trim();
    final email = _prefs!.getString(_keyUserEmail)?.trim();
    final phone = _prefs!.getString(_keyUserPhone)?.trim();
    return {
      'name': (name == null || name.isEmpty) ? 'Parent' : name,
      'email': (email == null || email.isEmpty) ? 'No email saved' : email,
      'phone': (phone == null || phone.isEmpty) ? 'No phone saved' : phone,
    };
  }

  Future<void> updateSignedInUser({
    required String fullName,
    required String phone,
  }) async {
    await init();
    await _prefs!.setString(_keyUserName, fullName.trim());
    await _prefs!.setString(_keyUserPhone, phone.trim());
  }

  Future<bool> getNotificationsEnabled() async {
    await init();
    return _prefs!.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await init();
    await _prefs!.setBool(_keyNotificationsEnabled, value);
  }

  Future<void> logout() async {
    await init();
    await _prefs!.setBool(_keyIsLoggedIn, false);
  }

  Future<List<ChildEntity>> _getChildrenRaw() async {
    await init();
    final raw = _prefs!.getString(_keyChildren);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final parsed = decoded
          .map((e) => ChildEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final cleaned = parsed.where((c) => !_isLegacySeedChild(c)).toList();

      if (cleaned.length != parsed.length) {
        await saveChildren(cleaned);
        final validIds = cleaned.map((e) => e.id).toSet();
        await _removeOrphanVaccinationRecords(validIds);

        final active = _prefs!.getString(_keyActiveChildId);
        if (active != null && !validIds.contains(active)) {
          if (cleaned.isEmpty) {
            await _prefs!.remove(_keyActiveChildId);
          } else {
            await _prefs!.setString(_keyActiveChildId, cleaned.first.id);
          }
        }
      }

      return cleaned;
    } catch (_) {
      return [];
    }
  }

  bool _isLegacySeedChild(ChildEntity child) {
    // Legacy seeded children from older mock builds.
    return child.id == '1' || child.id == '2';
  }

  Future<void> _removeOrphanVaccinationRecords(
    Set<String> validChildIds,
  ) async {
    final records = await getChildVaccinations();
    final filtered = records
        .where((r) => validChildIds.contains(r.childId))
        .toList();
    if (filtered.length != records.length) {
      await saveChildVaccinations(filtered);
    }
  }

  Future<List<ChildEntity>> getChildren() async {
    final children = await _getChildrenRaw();
    final records = await getChildVaccinations();
    final planned = _plannedDoses;
    final now = DateTime.now();

    return children.map((child) {
      final childRecords = records.where((r) => r.childId == child.id).toList();
      final completedIds = childRecords
          .where((r) => r.status == 'administered')
          .map((r) => r.plannedDoseId)
          .toSet();

      final activePlanned = planned.where((dose) {
        if (completedIds.contains(dose.id)) return true;
        return !_isBirthWindowMissed(
          dose: dose,
          scheduled: _scheduledDate(
            child.dateOfBirth,
            dose.recommendedAgeMonths,
          ),
          now: now,
        );
      }).toList();

      final totalVaccines = activePlanned.length;
      final activeIds = activePlanned.map((e) => e.id).toSet();
      final completedVaccines = completedIds
          .where((id) => activeIds.contains(id))
          .length;

      DateTime? nextDate;
      String? nextName;
      for (final dose in activePlanned) {
        if (completedIds.contains(dose.id)) continue;
        final candidateDate = _scheduledDate(
          child.dateOfBirth,
          dose.recommendedAgeMonths,
        );
        if (nextDate == null || candidateDate.isBefore(nextDate)) {
          nextDate = candidateDate;
          nextName = '${dose.vaccineName} (Dose ${dose.doseNumber})';
        }
      }

      return ChildEntity(
        id: child.id,
        name: child.name,
        dateOfBirth: child.dateOfBirth,
        photoUrl: child.photoUrl,
        totalVaccines: totalVaccines,
        completedVaccines: completedVaccines,
        nextVaccineDate: nextDate,
        nextVaccineName: nextName,
        isFullyProtected: completedVaccines >= totalVaccines,
      );
    }).toList();
  }

  Future<ChildEntity?> getChildById(String id) async {
    final children = await getChildren();
    for (final child in children) {
      if (child.id == id) return child;
    }
    return null;
  }

  Future<void> saveChildren(List<ChildEntity> children) async {
    await init();
    final raw = jsonEncode(children.map((c) => c.toJson()).toList());
    await _prefs!.setString(_keyChildren, raw);
  }

  Future<void> addChild(ChildEntity child) async {
    final children = await _getChildrenRaw();
    children.add(
      ChildEntity(
        id: child.id,
        name: child.name,
        dateOfBirth: child.dateOfBirth,
        photoUrl: child.photoUrl,
        totalVaccines: 0,
        completedVaccines: 0,
      ),
    );
    await saveChildren(children);
    await setActiveChildId(child.id);
  }

  Future<void> updateChild(ChildEntity child) async {
    final children = await _getChildrenRaw();
    final updated = children.map((c) {
      if (c.id != child.id) return c;
      return ChildEntity(
        id: child.id,
        name: child.name,
        dateOfBirth: child.dateOfBirth,
        photoUrl: child.photoUrl,
        totalVaccines: c.totalVaccines,
        completedVaccines: c.completedVaccines,
        nextVaccineDate: c.nextVaccineDate,
        nextVaccineName: c.nextVaccineName,
        isFullyProtected: c.isFullyProtected,
      );
    }).toList();
    await saveChildren(updated);
  }

  Future<void> deleteChild(String childId) async {
    final children = await _getChildrenRaw();
    final filtered = children.where((c) => c.id != childId).toList();
    await saveChildren(filtered);

    final records = await getChildVaccinations();
    final filteredRecords = records.where((r) => r.childId != childId).toList();
    await saveChildVaccinations(filteredRecords);

    final active = _prefs!.getString(_keyActiveChildId);
    if (active == childId) {
      if (filtered.isEmpty) {
        await _prefs!.remove(_keyActiveChildId);
      } else {
        await _prefs!.setString(_keyActiveChildId, filtered.first.id);
      }
    }
  }

  Future<void> setActiveChildId(String childId) async {
    await init();
    await _prefs!.setString(_keyActiveChildId, childId);
  }

  Future<String?> getPreferredChildId() async {
    await init();
    final children = await _getChildrenRaw();
    if (children.isEmpty) return null;

    final active = _prefs!.getString(_keyActiveChildId);
    if (active != null && children.any((c) => c.id == active)) {
      return active;
    }

    final fallback = children.first.id;
    await _prefs!.setString(_keyActiveChildId, fallback);
    return fallback;
  }

  Future<List<ChildVaccinationEntity>> getChildVaccinations({
    String? childId,
  }) async {
    await init();
    final raw = _prefs!.getString(_keyChildVaccinations);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final records = decoded
          .map(
            (e) =>
                ChildVaccinationEntity.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      if (childId == null) return records;
      return records.where((r) => r.childId == childId).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveChildVaccinations(
    List<ChildVaccinationEntity> records,
  ) async {
    await init();
    final raw = jsonEncode(records.map((e) => e.toJson()).toList());
    await _prefs!.setString(_keyChildVaccinations, raw);
  }

  Future<ChildVaccinationEntity> recordVaccination({
    required String childId,
    required String plannedDoseId,
    required DateTime administeredDate,
    String? remark,
    String? clinicName,
    String? lotNumber,
  }) async {
    final existing = await getChildVaccinations();
    final record = ChildVaccinationEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      childId: childId,
      plannedDoseId: plannedDoseId,
      administeredDate: administeredDate,
      status: 'administered',
      remark: remark,
      clinicName: clinicName,
      lotNumber: lotNumber,
    );

    final remaining = existing
        .where(
          (r) => !(r.childId == childId && r.plannedDoseId == plannedDoseId),
        )
        .toList();
    remaining.add(record);
    await saveChildVaccinations(remaining);
    return record;
  }

  List<PlannedVaccineDoseEntity> getPlannedDoses({String category = 'all'}) {
    if (category == 'all') {
      return List<PlannedVaccineDoseEntity>.from(_plannedDoses);
    }
    return _plannedDoses.where((d) => d.category == category).toList();
  }

  Future<List<VaccineEntity>> getRecordableDoses(String childId) async {
    final child = await getChildById(childId);
    if (child == null) return [];

    final records = await getChildVaccinations(childId: childId);
    final doneIds = records.map((r) => r.plannedDoseId).toSet();
    final now = DateTime.now();
    final list = <VaccineEntity>[];
    final nextByCode = _nextPendingDoseByCode(doneIds);

    for (final dose in _plannedDoses) {
      if (doneIds.contains(dose.id)) continue;
      if (nextByCode[dose.vaccineCode]?.id != dose.id) continue;
      final scheduled = _scheduledDate(
        child.dateOfBirth,
        dose.recommendedAgeMonths,
      );
      final status = _statusForDose(dose, scheduled, now);
      final canAdminister = _canAdministerDose(
        dose: dose,
        scheduled: scheduled,
        now: now,
      );
      if (!canAdminister) continue;
      list.add(
        VaccineEntity(
          id: dose.id,
          plannedDoseId: dose.id,
          name: dose.vaccineName,
          disease: dose.disease,
          doseNumber: dose.doseNumber,
          totalDoses: dose.totalDoses,
          scheduledDate: scheduled,
          status: status,
          ageGroup: _ageGroupLabel(dose.recommendedAgeMonths),
          category: dose.category,
          recommendedAgeMonths: dose.recommendedAgeMonths,
          canAdminister: canAdminister,
          windowMissed: _isBirthWindowMissed(
            dose: dose,
            scheduled: scheduled,
            now: now,
          ),
        ),
      );
    }

    list.sort((a, b) {
      final aDate = a.scheduledDate ?? DateTime.now();
      final bDate = b.scheduledDate ?? DateTime.now();
      return aDate.compareTo(bDate);
    });
    return list;
  }

  Future<List<VaccineScheduleGroup>> getComputedSchedule(
    String childId, {
    String filter = 'all',
  }) async {
    final child = await getChildById(childId);
    if (child == null) return [];

    final records = await getChildVaccinations(childId: childId);
    final doneByDoseId = <String, ChildVaccinationEntity>{};
    for (final r in records) {
      doneByDoseId[r.plannedDoseId] = r;
    }

    final planned = getPlannedDoses(category: filter);
    final now = DateTime.now();
    final grouped = <int, List<VaccineEntity>>{};

    for (final dose in planned) {
      final scheduled = _scheduledDate(
        child.dateOfBirth,
        dose.recommendedAgeMonths,
      );
      final doneRecord = doneByDoseId[dose.id];
      final windowMissed = _isBirthWindowMissed(
        dose: dose,
        scheduled: scheduled,
        now: now,
      );
      final canAdminister =
          doneRecord == null &&
          _canAdministerDose(dose: dose, scheduled: scheduled, now: now);
      final status = doneRecord != null
          ? VaccineStatus.done
          : _statusForDose(dose, scheduled, now);
      final item = VaccineEntity(
        id: dose.id,
        plannedDoseId: dose.id,
        name: dose.vaccineName,
        disease: dose.disease,
        doseNumber: dose.doseNumber,
        totalDoses: dose.totalDoses,
        scheduledDate: scheduled,
        administeredDate: doneRecord?.administeredDate,
        status: status,
        notes: doneRecord?.remark,
        clinicName: doneRecord?.clinicName,
        lotNumber: doneRecord?.lotNumber,
        ageGroup: _ageGroupLabel(dose.recommendedAgeMonths),
        category: dose.category,
        recommendedAgeMonths: dose.recommendedAgeMonths,
        canAdminister: canAdminister,
        windowMissed: windowMissed,
      );
      grouped.putIfAbsent(dose.recommendedAgeMonths, () => []);
      grouped[dose.recommendedAgeMonths]!.add(item);
    }

    final months = grouped.keys.toList()..sort();
    return months.map((m) {
      final doses = grouped[m]!;
      final groupStatus = _groupStatus(doses.map((e) => e.status).toList());
      final scheduled = _scheduledDate(child.dateOfBirth, m);
      return VaccineScheduleGroup(
        ageGroup: _ageGroupLabel(m),
        dateLabel: _relativeDateLabel(scheduled, now),
        vaccines: doses,
        groupStatus: groupStatus,
      );
    }).toList();
  }

  Future<List<VaccinationRecordEntity>> getVaccinationHistory({
    String? childId,
  }) async {
    final records = await getChildVaccinations(childId: childId);
    final children = await getChildren();
    final childById = {for (final c in children) c.id: c};
    final plannedById = {for (final p in _plannedDoses) p.id: p};

    final mapped = <VaccinationRecordEntity>[];
    for (final r in records) {
      final child = childById[r.childId];
      final planned = plannedById[r.plannedDoseId];
      if (child == null || planned == null) continue;
      mapped.add(
        VaccinationRecordEntity(
          id: r.id,
          childId: r.childId,
          childName: child.name,
          vaccineName: planned.vaccineName,
          disease: planned.disease,
          doseLabel: 'Dose ${planned.doseNumber} of ${planned.totalDoses}',
          administeredDate: r.administeredDate,
          clinicName: r.clinicName,
          lotNumber: r.lotNumber,
          status: r.status,
          notes: r.remark,
        ),
      );
    }

    mapped.sort((a, b) => b.administeredDate.compareTo(a.administeredDate));
    return mapped;
  }

  Future<List<NotificationEntity>> getNotifications() async {
    final enabled = await getNotificationsEnabled();
    if (!enabled) return [];

    final children = await getChildren();
    final records = await getChildVaccinations();
    final done = records.map((r) => '${r.childId}|${r.plannedDoseId}').toSet();
    final read = await _getReadNotificationIds();
    final dismissed = await _getDismissedNotificationIds();
    final now = DateTime.now();

    final list = <NotificationEntity>[];

    for (final child in children) {
      for (final dose in _plannedDoses) {
        final key = '${child.id}|${dose.id}';
        if (done.contains(key) || dismissed.contains(key)) continue;
        final scheduled = _scheduledDate(
          child.dateOfBirth,
          dose.recommendedAgeMonths,
        );
        final status = _statusForDose(dose, scheduled, now);
        if (dose.recommendedAgeMonths == 0 && status == VaccineStatus.overdue) {
          // Birth-dose window is missed; do not keep notifying indefinitely.
          continue;
        }
        if (status != VaccineStatus.overdue &&
            status != VaccineStatus.dueSoon) {
          continue;
        }
        final days = scheduled
            .difference(DateTime(now.year, now.month, now.day))
            .inDays;
        final title = '${child.name} - ${dose.vaccineName}';
        final body = status == VaccineStatus.overdue
            ? (dose.recommendedAgeMonths == 0
                  ? 'Birth-dose window exceeded (more than 7 days after birth).'
                  : 'This dose is overdue by ${days.abs()} day(s).')
            : 'This dose is due in $days day(s).';
        list.add(
          NotificationEntity(
            id: key,
            title: title,
            body: body,
            priority: status == VaccineStatus.overdue
                ? NotificationPriority.urgent
                : NotificationPriority.dueSoon,
            createdAt: now,
            isRead: read.contains(key),
            actionLabel: 'Open Schedule',
            vaccineName: dose.vaccineName,
          ),
        );
      }
    }

    list.sort((a, b) {
      final pa = _priorityWeight(a.priority);
      final pb = _priorityWeight(b.priority);
      return pa.compareTo(pb);
    });
    return list;
  }

  Future<void> markNotificationRead(String id) async {
    final ids = await _getReadNotificationIds();
    ids.add(id);
    await _prefs!.setStringList(_keyReadNotificationIds, ids.toList());
  }

  Future<void> dismissNotification(String id) async {
    final dismissed = await _getDismissedNotificationIds();
    dismissed.add(id);
    await _prefs!.setStringList(
      _keyDismissedNotificationIds,
      dismissed.toList(),
    );
  }

  Future<List<GuidanceArticleEntity>> getGuidanceArticles({
    String? category,
  }) async {
    await init();
    final rawRemarks = _prefs!.getString(_keyGuidanceRemarks);
    Map<String, List<GuidanceRemarkEntity>> remarksByArticle = {};
    if (rawRemarks != null && rawRemarks.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawRemarks) as Map<String, dynamic>;
        remarksByArticle = decoded.map((key, value) {
          final list = (value as List<dynamic>)
              .map(
                (e) =>
                    GuidanceRemarkEntity.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
          return MapEntry(key, list);
        });
      } catch (_) {
        remarksByArticle = {};
      }
    }

    final articles = _baseGuidanceArticles.map((a) {
      return a.copyWith(remarks: remarksByArticle[a.id] ?? const []);
    }).toList();

    if (category == null) return articles;
    return articles.where((a) => a.category == category).toList();
  }

  Future<void> addGuidanceRemark({
    required String articleId,
    required String text,
  }) async {
    await init();
    final articles = await getGuidanceArticles();
    final remarksMap = <String, List<GuidanceRemarkEntity>>{
      for (final a in articles)
        a.id: List<GuidanceRemarkEntity>.from(a.remarks),
    };

    final list = remarksMap.putIfAbsent(articleId, () => []);
    list.insert(
      0,
      GuidanceRemarkEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text.trim(),
        createdAt: DateTime.now(),
      ),
    );

    final enc = <String, dynamic>{};
    remarksMap.forEach((key, value) {
      enc[key] = value.map((e) => e.toJson()).toList();
    });
    await _prefs!.setString(_keyGuidanceRemarks, jsonEncode(enc));
  }

  Future<Set<String>> _getReadNotificationIds() async {
    await init();
    return (_prefs!.getStringList(_keyReadNotificationIds) ?? []).toSet();
  }

  Future<Set<String>> _getDismissedNotificationIds() async {
    await init();
    return (_prefs!.getStringList(_keyDismissedNotificationIds) ?? []).toSet();
  }

  Map<String, PlannedVaccineDoseEntity> _nextPendingDoseByCode(
    Set<String> doneIds,
  ) {
    final grouped = <String, List<PlannedVaccineDoseEntity>>{};
    for (final dose in _plannedDoses) {
      grouped.putIfAbsent(dose.vaccineCode, () => []);
      grouped[dose.vaccineCode]!.add(dose);
    }

    final result = <String, PlannedVaccineDoseEntity>{};
    grouped.forEach((code, doses) {
      doses.sort((a, b) {
        final byAge = a.recommendedAgeMonths.compareTo(b.recommendedAgeMonths);
        if (byAge != 0) return byAge;
        return a.doseNumber.compareTo(b.doseNumber);
      });
      for (final d in doses) {
        if (!doneIds.contains(d.id)) {
          result[code] = d;
          break;
        }
      }
    });
    return result;
  }

  bool _isBirthWindowMissed({
    required PlannedVaccineDoseEntity dose,
    required DateTime scheduled,
    required DateTime now,
  }) {
    if (dose.recommendedAgeMonths != 0) return false;
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfWindow = DateTime(
      scheduled.year,
      scheduled.month,
      scheduled.day + 7,
    );
    return startOfToday.isAfter(endOfWindow);
  }

  bool _canAdministerDose({
    required PlannedVaccineDoseEntity dose,
    required DateTime scheduled,
    required DateTime now,
  }) {
    final startOfToday = DateTime(now.year, now.month, now.day);
    if (dose.recommendedAgeMonths == 0) {
      // Birth doses are valid only in the first 7 days.
      return !_isBirthWindowMissed(dose: dose, scheduled: scheduled, now: now);
    }
    // Catch-up is allowed, but not before the recommended date.
    return !scheduled.isAfter(startOfToday);
  }

  VaccineStatus _statusForDose(
    PlannedVaccineDoseEntity dose,
    DateTime scheduled,
    DateTime now,
  ) {
    final startOfToday = DateTime(now.year, now.month, now.day);
    if (dose.recommendedAgeMonths == 0) {
      if (_isBirthWindowMissed(dose: dose, scheduled: scheduled, now: now)) {
        return VaccineStatus.overdue;
      }
      return VaccineStatus.dueSoon;
    }
    if (scheduled.isBefore(startOfToday)) return VaccineStatus.overdue;
    final days = scheduled.difference(startOfToday).inDays;
    if (days <= 7) return VaccineStatus.dueSoon;
    return VaccineStatus.upcoming;
  }

  VaccineStatus _groupStatus(List<VaccineStatus> statuses) {
    if (statuses.any((s) => s == VaccineStatus.overdue)) {
      return VaccineStatus.overdue;
    }
    if (statuses.any((s) => s == VaccineStatus.dueSoon)) {
      return VaccineStatus.dueSoon;
    }
    if (statuses.every((s) => s == VaccineStatus.done)) {
      return VaccineStatus.done;
    }
    return VaccineStatus.upcoming;
  }

  int _priorityWeight(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return 0;
      case NotificationPriority.dueSoon:
        return 1;
      case NotificationPriority.info:
        return 2;
      case NotificationPriority.success:
        return 3;
    }
  }

  DateTime _scheduledDate(DateTime dob, int ageMonths) {
    return DateTime(dob.year, dob.month + ageMonths, dob.day);
  }

  String _ageGroupLabel(int months) {
    if (months == 0) return 'AT BIRTH';
    if (months == 132) return '11-13 YEARS';
    if (months < 12) return '$months MONTHS';
    if (months % 12 == 0) return '${months ~/ 12} YEARS';
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    return '$years YEARS $remainingMonths MONTHS';
  }

  String _relativeDateLabel(DateTime target, DateTime now) {
    final startToday = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(target.year, target.month, target.day);
    final days = dateOnly.difference(startToday).inDays;
    if (days == 0) return 'Today';
    if (days > 0 && days <= 30) return 'In $days day(s)';
    if (days < 0 && days >= -30) return '${days.abs()} day(s) ago';
    final month = _monthName(target.month);
    return '$month ${target.year}';
  }

  String _monthName(int month) {
    const names = <String>[
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month];
  }

  static const List<PlannedVaccineDoseEntity> _plannedDoses = [
    PlannedVaccineDoseEntity(
      id: 'dose_bcg_1',
      vaccineCode: 'BCG',
      vaccineName: 'BCG',
      disease: 'Tuberculosis',
      doseNumber: 1,
      totalDoses: 1,
      recommendedAgeMonths: 0,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_hepb_1',
      vaccineCode: 'HBV',
      vaccineName: 'HBV',
      disease: 'Hepatitis B',
      doseNumber: 1,
      totalDoses: 1,
      recommendedAgeMonths: 0,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_dtp_1',
      vaccineCode: 'HexA',
      vaccineName: 'HexA',
      disease: 'Diphtheria, Tetanus, Pertussis, Hepatitis B, IPV, Hib',
      doseNumber: 1,
      totalDoses: 3,
      recommendedAgeMonths: 2,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_pcv_1',
      vaccineCode: 'PCV',
      vaccineName: 'PCV',
      disease: 'Pneumococcal Conjugate',
      doseNumber: 1,
      totalDoses: 3,
      recommendedAgeMonths: 2,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_vpo_1',
      vaccineCode: 'VPO',
      vaccineName: 'VPO',
      disease: 'Poliomyelitis (oral polio)',
      doseNumber: 1,
      totalDoses: 3,
      recommendedAgeMonths: 2,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_hexa_2',
      vaccineCode: 'HexA',
      vaccineName: 'HexA',
      disease: 'Diphtheria, Tetanus, Pertussis, Hepatitis B, IPV, Hib',
      doseNumber: 2,
      totalDoses: 3,
      recommendedAgeMonths: 4,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_pcv_2',
      vaccineCode: 'PCV',
      vaccineName: 'PCV',
      disease: 'Pneumococcal disease',
      doseNumber: 2,
      totalDoses: 3,
      recommendedAgeMonths: 5,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_vpo_2',
      vaccineCode: 'VPO',
      vaccineName: 'VPO',
      disease: 'Poliomyelitis (oral polio)',
      doseNumber: 2,
      totalDoses: 3,
      recommendedAgeMonths: 5,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_mmr_1',
      vaccineCode: 'ROR',
      vaccineName: 'ROR',
      disease: 'Measles, Mumps, Rubella',
      doseNumber: 1,
      totalDoses: 2,
      recommendedAgeMonths: 9,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_hexa_3',
      vaccineCode: 'HexA',
      vaccineName: 'HexA',
      disease: 'Diphtheria, Tetanus, Pertussis, Hepatitis B, IPV, Hib',
      doseNumber: 3,
      totalDoses: 3,
      recommendedAgeMonths: 18,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_pcv_3',
      vaccineCode: 'PCV',
      vaccineName: 'PCV',
      disease: 'Pneumococcal disease',
      doseNumber: 3,
      totalDoses: 3,
      recommendedAgeMonths: 72,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_vpo_3',
      vaccineCode: 'VPO',
      vaccineName: 'VPO',
      disease: 'Poliomyelitis (oral polio)',
      doseNumber: 3,
      totalDoses: 3,
      recommendedAgeMonths: 72,
      category: 'mandatory',
    ),
    PlannedVaccineDoseEntity(
      id: 'dose_mmr_2',
      vaccineCode: 'ROR',
      vaccineName: 'ROR',
      disease: 'Measles, Mumps, Rubella',
      doseNumber: 2,
      totalDoses: 2,
      recommendedAgeMonths: 132,
      category: 'mandatory',
    ),
  ];

  static const List<GuidanceArticleEntity> _baseGuidanceArticles = [
    GuidanceArticleEntity(
      id: 'guide_side_sore_arm',
      title: 'Sore Arm',
      category: 'side_effects',
      content:
          'Pain, redness, or swelling at injection site can appear for 1 to 2 days.',
    ),
    GuidanceArticleEntity(
      id: 'guide_advice_hydrate',
      title: 'Hydration Advice',
      category: 'advice',
      content:
          'Offer water frequently and monitor temperature in the first 24 hours.',
    ),
    GuidanceArticleEntity(
      id: 'guide_warning_breathing',
      title: 'Emergency Warning Signs',
      category: 'warning_signs',
      content:
          'Seek urgent care if breathing difficulty, facial swelling, or persistent high fever appears.',
    ),
    GuidanceArticleEntity(
      id: 'guide_schedule_birth_window',
      title: 'Birth-Dose Window (BCG & HBV)',
      category: 'advice',
      content:
          'BCG and HBV are expected at birth. If not administered within the first 7 days, the birth window is considered missed in this app.',
    ),
    GuidanceArticleEntity(
      id: 'guide_vax_hexa',
      title: 'HexA Protects Against',
      category: 'advice',
      content:
          'HexA covers Diphtheria, Tetanus, Pertussis, Hepatitis B, Polio (IPV), and Hib.',
    ),
    GuidanceArticleEntity(
      id: 'guide_vax_pcv',
      title: 'PCV Protects Against',
      category: 'advice',
      content:
          'PCV helps prevent severe pneumococcal disease such as meningitis, sepsis, and pneumonia.',
    ),
    GuidanceArticleEntity(
      id: 'guide_vax_vpo',
      title: 'VPO Protects Against',
      category: 'advice',
      content:
          'Oral polio vaccine (VPO) protects against poliomyelitis and supports community protection.',
    ),
    GuidanceArticleEntity(
      id: 'guide_vax_ror',
      title: 'ROR Protects Against',
      category: 'advice',
      content: 'ROR vaccine protects against measles, mumps, and rubella.',
    ),
    GuidanceArticleEntity(
      id: 'guide_algeria_schedule',
      title: 'Algeria Routine Timeline',
      category: 'advice',
      content:
          'Reference timeline used in this app: Birth (BCG, HBV), 2m (HexA, PCV, VPO), 4m (HexA), 5m (PCV, VPO), 9m (ROR), 18m (HexA), 6y (PCV, VPO), 11-13y (ROR booster).',
    ),
    GuidanceArticleEntity(
      id: 'guide_algeria_disease_map',
      title: 'Vaccine-Disease Quick Map',
      category: 'advice',
      content:
          'BCG -> severe childhood TB. VPO/IPV -> polio. HBV -> hepatitis B. Diphtheria/Tetanus/Pertussis/Hib components in HexA protect against their corresponding diseases. PCV -> pneumococcal meningitis/sepsis/pneumonia risk. ROR -> measles, mumps, rubella.',
    ),
  ];
}
