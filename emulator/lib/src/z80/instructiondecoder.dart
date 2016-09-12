
import "package:emulator/src/z80/instructions.dart" as Instructions;

class InstructionDecoder extends Z80
{

  InstructionDecoder.fromZ80(Z80.Z80 z) : super.clone(z);

  Instructions.Instruction pullInstruction() {
    final addr = this.cpur.PC;
    final OpPrefix p = _prefix;
    final op = _mmu.pullMem(addr, DataType.BYTE);
    if (op == 0xCB && p == OpPrefix.None)
      _prefix = OpCode.CB;
    else
      _prefix = OpCode.None;
    switch (p)
    {
      case (OpPrefix.None) :
        final infoList = instInfos;
        break;
      case (OpPrefix.CB) :
        final infoList = instInfos_CB;
        break;
      default: assert(false);
    }
    final info = infoList[op];
    switch (info.byteSize)
    {
      case (1): final data = null; break;
      case (2): final data = _mmu.pullMem(this.cpur.PC + 1, DataType.BYTE); break;
      case (3): final data = _mmu.pullMem(this.cpur.PC + 1, DataType.WORD); break;
      default : assert(false);
    }
    this.cpur.PC += info.byteSize;
    return Instruction(addr, p, op, data);
  }

}
