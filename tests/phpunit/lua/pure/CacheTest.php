<?php
namespace TemplateData\Test;
use Scribunto_LuaEngineTestBase;
/**
 * @group TemplateData
 * @group TemplateDataCache
 *
 * @license GNU GPL v2+
 *
 * @author John Erling Blad < jeblad@gmail.com >
 */
class CacheTest extends Scribunto_LuaEngineTestBase {
	protected static $moduleName = 'CacheTest';
	/**
	 * @see Scribunto_LuaEngineTestBase::getTestModules()
	 */
	function getTestModules() {
		return parent::getTestModules() + [
			'CacheTest' => __DIR__ . '/CacheTest.lua'
		];
	}
}