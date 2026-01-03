import '../models/scenario.dart';

final List<Scenario> initialScenarios = [
  Scenario(
    id: 'intro_1',
    text: 'Nhà Trần mới thành lập, lòng dân chưa yên. Bạn sẽ làm gì để củng cố quyền lực?',
    leftChoice: Choice(
      text: 'Giảm thuế cho dân',
      effect: ScenarioEffect(people: 10, money: -10),
    ),
    rightChoice: Choice(
      text: 'Chiêu mộ binh lính',
      effect: ScenarioEffect(army: 10, money: -5),
    ),
  ),
  Scenario(
    id: 'event_mogol',
    text: 'Sứ giả Mông Cổ đến đòi cống nạp. Thái độ rất ngạo mạn.',
    leftChoice: Choice(
      text: 'Chấp nhận cống nạp',
      effect: ScenarioEffect(money: -20, people: -5, army: -5), // Avoid war but lose face/money
    ),
    rightChoice: Choice(
      text: 'Đuổi về, chuẩn bị chiến tranh',
      effect: ScenarioEffect(army: 5, religion: 5, money: -5), // Boost morale but cost preparations
    ),
  ),
  Scenario(
    id: 'internal_conflict',
    text: 'Một quan lại trong triều bị tố cáo tham nhũng.',
    leftChoice: Choice(
      text: 'Trừng trị nghiêm khắc',
      effect: ScenarioEffect(money: 10, people: 5, religion: -5), // Seize assets, people happy, nobles unhappy
    ),
    rightChoice: Choice(
      text: 'Tha thứ để giữ hòa khí',
      effect: ScenarioEffect(people: -10, religion: 5), // Nobles happy, people angry
    ),
  ),
  Scenario(
    id: 'harvest',
    text: 'Năm nay được mùa lớn.',
    leftChoice: Choice(
      text: 'Tích trữ lương thực',
      effect: ScenarioEffect(money: 10, army: 5),
    ),
    rightChoice: Choice(
      text: 'Mở tiệc khao quân dân',
      effect: ScenarioEffect(people: 10, religion: 5, money: -5),
    ),
  ),
  Scenario(
    id: 'flood',
    text: 'Đê sông Hồng có nguy cơ vỡ.',
    leftChoice: Choice(
      text: 'Huy động dân đắp đê',
      effect: ScenarioEffect(people: -5, money: -5),
    ),
    rightChoice: Choice(
      text: 'Cầu trời khấn phật',
      effect: ScenarioEffect(religion: 5, people: -20), // Risk disaster
    ),
  ),
];
